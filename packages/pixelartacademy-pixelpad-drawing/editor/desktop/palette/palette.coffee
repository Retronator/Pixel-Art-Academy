AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.Palette extends LOI.Assets.SpriteEditor.Palette
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.Palette'
  @register @id()
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    # Loaded from the PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop namespace.
    subNamespace: true
    variables:
      changeColor: AEc.ValueTypes.Trigger
      
  onCreated: ->
    super arguments...
    
    @asset = new ComputedField =>
      @interface.getLoaderForActiveFile()?.asset()
      
    @customPalette = new ComputedField =>
      @asset()?.customPalette
      
    @paletteId = new ComputedField =>
      @asset()?.palette?._id

    paletteField = @palette
    @palette = new ComputedField =>
      return unless palette = paletteField()

      # Randomize palette for the tray.
      for ramp in palette.ramps
        ramp.blendOffset = Math.random()

        for shade in ramp.shades
          shade.offset = _.random 0, 2

      palette

  trayClass: ->
    'tray' if @customPalette()

  swatchesClass: ->
    'swatches' if @paletteId()

  paletteNameClass: ->
    return unless palette = @paletteData()

    _.kebabCase palette.name

  colorsStyle: ->
    # We only need to style the custom palette tray.
    return unless @customPalette()
    return unless palette = @palette()

    # Calculate the width of the palette.
    height = 120
    shadeSize = 11
    rampWidth = 15
    rampBottomMargin = 6
    rampRightMargin = 3

    width = rampWidth
    columnHeight = 0

    for ramp in palette.ramps
      rampHeight = ramp.shades.length * shadeSize
      columnHeight += rampHeight + rampBottomMargin

      if columnHeight > height
        # We overflow into the new line.
        width += rampRightMargin + rampWidth
        columnHeight = rampHeight + rampBottomMargin

    # Tray should be at least 32 wide.
    width = Math.max 32, width

    width: "#{width}rem"

  shadeStyle: ->
    return unless @customPalette()
    shade = @currentData()

    marginLeft: "#{shade.offset}rem"

  colorStyle: ->
    # Custom palette tray doesn't use colors via style.
    return if @customPalette()

    super arguments...
  
  onClickColor: ->
    super arguments...
    
    @audio.changeColor()
    
  class @TrayRamp extends AM.Component
    @register 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.Palette.TrayRamp'

    onRendered: ->
      super arguments...

      @autorun (computation) =>
        ramp = @data()

        canvas = @$('.canvas')[0]
        canvas.width = 16
        canvas.height = ramp.shades.length * 11 + 2

        context = canvas.getContext '2d', willReadFrequently: true
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
                x: shade.offset + 7
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

        # Add cast shadow.
        for y in [0...canvas.height]
          for x in [0...canvas.width - 1]
            pixelOffset = (x + y * canvas.width) * 4
            
            continue unless imageData.data[pixelOffset + 7] and not imageData.data[pixelOffset + 3]
            
            neighborR = Math.max 0, imageData.data[pixelOffset + 4] - 150
            neighborG = Math.max 0, imageData.data[pixelOffset + 5] - 150
            neighborB = Math.max 0, imageData.data[pixelOffset + 6] - 150
            neighborValue = Math.max neighborR, Math.max neighborG, neighborB
            
            imageData.data[pixelOffset] = 178
            imageData.data[pixelOffset + 1] = 178
            imageData.data[pixelOffset + 2] = 178
            imageData.data[pixelOffset + 3] = 255 - neighborValue * 2
            
        context.putImageData imageData, 0, 0
