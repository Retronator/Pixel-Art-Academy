AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Drawing.Editor.Desktop.Palette extends LOI.Assets.Components.Palette
  @register 'PixelArtAcademy.PixelBoy.Apps.Drawing.Editor.Desktop.Palette'

  palette: ->
    return unless palette = super

    # Go over all shades of all ramps.
    for ramp in palette.ramps
      ramp.blendOffset = Math.random()

      for shade in ramp.shades
        shade.offset = _.random 0, 2

    palette

  trayClass: ->
    'tray' if @options.paletteData?()

  swatchesClass: ->
    'swatches' if @options.paletteId?()

  paletteNameClass: ->
    return unless paletteId = @options.paletteId()
    return unless palette = LOI.Assets.Palette.documents.findOne paletteId

    _.kebabCase palette.name

  shadeStyle: ->
    return unless @options.paletteData?()
    shade = @currentData()

    marginLeft: "#{shade.offset}rem"

  colorStyle: ->
    # Tray skin doesn't use colors via style.
    return if @trayClass()

    super

  class @TrayRamp extends AM.Component
    @register 'PixelArtAcademy.PixelBoy.Apps.Drawing.Editor.Desktop.Palette.TrayRamp'

    onRendered: ->
      super

      @autorun (computation) =>
        ramp = @data()

        canvas = @$('.canvas')[0]
        canvas.width = 15
        canvas.height = ramp.shades.length * 11 + 2

        context = canvas.getContext '2d'
        imageData = context.getImageData 0, 0, canvas.width, canvas.height

        previousRowTotalPower = null

        for y in [0...canvas.height]
          previousTotalPower = 0
          rowTotalPower = []

          for x in [0...canvas.width]
            color = null

            previousColor = null
            previousPower = 0

            totalPower = 0

            for shade, index in ramp.shades
              center =
                x: shade.offset + 6
                y: index * 11 + 6

              distanceToCenter = Math.sqrt Math.pow(x - center.x, 2) + Math.pow(y - center.y, 2)
              continue if distanceToCenter > 10

              power = 2 * Math.pow(distanceToCenter, 3) / Math.pow(10, 3) - 3 * Math.pow(distanceToCenter, 2) / Math.pow(10, 2) + 1
              totalPower += power

              if totalPower > 0.34
                color = shade.color

              if color and previousColor
                blendingChance = power / (power + previousPower)
                color = if 0.5 + 0.2 * Math.sin(2 * ramp.blendOffset + x * 0.6 + y * 0.2) < blendingChance then shade.color else previousColor

              previousPower = power
              previousColor = shade.color

            pixelOffset = (x + y * canvas.width) * 4

            shadePower = 1

            if previousTotalPower or previousRowTotalPower?[x]
              gradientX = Math.max 0, previousTotalPower - totalPower
              gradientY = Math.max 0, totalPower - (previousRowTotalPower?[x] or 0)

              gradient = 3 * gradientY + 5 * gradientX

              shadePower = 0.8 if 0.5 < gradient

            if color
              imageData.data[pixelOffset] = Math.pow(color.r, shadePower) * 255
              imageData.data[pixelOffset + 1] = Math.pow(color.g, shadePower) * 255
              imageData.data[pixelOffset + 2] = Math.pow(color.b, shadePower) * 255

            imageData.data[pixelOffset + 3] = if color then 255 else 0

            rowTotalPower.push totalPower
            previousTotalPower = totalPower

          previousRowTotalPower = rowTotalPower

        context.putImageData imageData, 0, 0
