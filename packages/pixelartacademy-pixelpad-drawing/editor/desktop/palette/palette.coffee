AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

_trayContentHeight = 112
_trayShadeSize = 11
_trayRampWidth = 15
_trayCanvasTopMargin = -2
_trayCanvasLeftMargin = -1
_trayRampBottomMargin = 6
_trayRampRightMargin = 3

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

      index = 0
      
      for ramp in palette.ramps
        # Randomize palette for the tray.
        ramp.blendOffset = Math.random()

        for shade in ramp.shades
          shade.rampShadesLength = ramp.shades.length
          shade.offset = _.random 0, 2
          shade.symbol = PAA.PixelPad.Apps.Drawing.Editor.ColorHelp.symbols[index]
          index++

      palette
    
    # Reset display of all hints.
    @autorun (computation) =>
      return unless desktop = @interface.getEditorForActiveFile().desktop
      return if desktop.active()
      return unless asset = desktop.activeAsset()
      return unless asset instanceof PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
      return unless asset.initialized()
      asset.hintsEngineComponents.overlaid.displayAllColorErrors false

    @colorHelp = new @constructor.ColorHelp @
    
  onBackButton: ->
    return unless @colorHelp.visible()
    
    @colorHelp.visible false
    
    # Inform that we've handled the back button.
    true
    
  trayClass: ->
    'tray' if @customPalette()

  swatchesClass: ->
    'swatches' if @paletteId()

  paletteNameClass: ->
    return unless palette = @paletteData()

    _.kebabCase palette.name

  forceSymbolsVisibleClass: ->
    'force-symbols-visible' if @colorHelp.visible()
    
  colorsStyle: ->
    # We only need to style the custom palette tray.
    return unless @customPalette()
    return unless palette = @palette()

    # Calculate the width of the palette.
    width = _trayRampWidth
    columnHeight = 0

    for ramp in palette.ramps when ramp.shades.length
      verticalSeparation = @constructor.TrayRamp.getVerticalShadeSeparation ramp.shades.length
      rampHeight = (ramp.shades.length - 1) * verticalSeparation + _trayShadeSize
      columnHeight += rampHeight + _trayRampBottomMargin

      if columnHeight > _trayContentHeight
        # We overflow into the new line.
        width += _trayRampRightMargin + _trayRampWidth
        columnHeight = rampHeight + _trayRampBottomMargin

    # Tray should be at least 32 wide.
    width = Math.max 32, width

    width: "#{width}rem"

  shadeStyle: ->
    return unless @customPalette()
    shade = @currentData()

    verticalSeparation = @constructor.TrayRamp.getVerticalShadeSeparation shade.rampShadesLength

    height: "#{verticalSeparation + 2}rem"
    marginLeft: "#{shade.offset}rem"

  colorStyle: ->
    # Custom palette tray doesn't use colors via style.
    return if @customPalette()

    super arguments...
  
  showColorSymbol: ->
    PAA.PixelPad.Apps.Drawing.Editor.ColorHelp.hintStyle() is PAA.PixelPad.Apps.Drawing.Editor.ColorHelp.HintStyle.Symbols
  
  colorSymbolStyle: ->
    shade = @currentData()
    
    color: "##{shade.accentColor.getHexString()}"
  
  showColorHelp: ->
    asset = @interface.getEditorForActiveFile().desktop.activeAsset()
    asset instanceof PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  
  events: ->
    super(arguments...).concat
      'click .color-help-button': @onClickColorHelpButton
  
  onClickColor: (event) ->
    super arguments...
    
    @audio.changeColor()
    
  onClickColorHelpButton: (event) ->
    @colorHelp.visible not @colorHelp.visible()
    
  class @TrayRamp extends AM.Component
    @register 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.Palette.TrayRamp'

    @getVerticalShadeSeparation: (numberOfShades) ->
      # Fit shades into the tray content height.
      return _trayShadeSize if numberOfShades is 1
      
      Math.min _trayShadeSize, Math.floor (_trayContentHeight - _trayRampBottomMargin - _trayShadeSize) / (numberOfShades - 1)

    onRendered: ->
      super arguments...

      @autorun (computation) =>
        ramp = @data()
        
        verticalSeparation = @constructor.getVerticalShadeSeparation ramp.shades.length

        canvas = @$('.canvas')[0]
        canvas.width = _trayRampWidth - _trayCanvasLeftMargin
        canvas.height = (ramp.shades.length - 1) * verticalSeparation + _trayShadeSize - _trayCanvasTopMargin

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
                y: index * verticalSeparation + 6

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
