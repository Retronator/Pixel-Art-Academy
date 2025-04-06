AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
AEc = Artificial.Echo
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.PaletteSelection.Page.Palette extends PAA.PixelPad.Apps.Drawing.PaletteSelection.Page
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.PaletteSelection.Page.Palette'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @darkestColor = new ReactiveField null
    @brightestColor = new ReactiveField null
    @accentColor = new ReactiveField null

    Tracker.autorun (computation) =>
      return unless pixelArtAcademyPalette = LOI.palette()
      return unless pageTemplateImageData = @constructor.pageTemplateImageData()
      computation.stop()

      colors = []
      
      palette = @data()
      for ramp in palette.ramps
        for shade in ramp.shades
          color = THREE.Color.fromObject shade
          colors.push color
          
          lch = color.getLCh()
          color.luminance = lch.l
          
          if lch.l < darkestColorLuminance
            darkestColor = color
            darkestColorLuminance = lch.l
            
          if lch.l > brightestColorLuminance
            brightestColor = color
            brightestColorLuminance = lch.l
            
      sortedColors = _.sortBy colors, (color) => color.luminance
      
      darkestColor = sortedColors[0]
      
      if colors.length is 1
        brightestColor = pixelArtAcademyPalette.color LOI.Assets.Palette.Atari2600.hues.gray, 8
        accentColor = pixelArtAcademyPalette.color LOI.Assets.Palette.Atari2600.hues.gray, 7
        
      else
        brightestColor = sortedColors[sortedColors.length - 1]
        
        if colors.length is 2
          brightestColorLCh = color.getLCh()
          accentColor = new THREE.Color().setLCh brightestColorLCh.l * 0.9, brightestColorLCh.c, brightestColorLCh.h
          
        else
          accentColor = sortedColors[sortedColors.length - 2]
      
      @darkestColor darkestColor
      @brightestColor brightestColor
      @accentColor accentColor
      
      for x in [0...@width]
        for y in [0...@height]
          index = (y * @width + x) * 4
          color = if pageTemplateImageData.data[index] then brightestColor else darkestColor
          
          @topCanvasImageData.data[index] = color.r * 255
          @topCanvasImageData.data[index + 1] = color.g * 255
          @topCanvasImageData.data[index + 2] = color.b * 255
          
      rowsCount = Math.ceil colors.length / 10
      colorsPerRow = Math.floor colors.length / rowsCount
      colorsRemainder = colors.length % rowsCount
      
      colorRows = []
      
      for rowIndex in [0...rowsCount]
        rowColors = []
        colorsCount = colorsPerRow
        colorsCount++ if rowIndex < colorsRemainder
        
        rowColors.push colors.shift() for colorIndex in [0...colorsCount]
        colorRows.push rowColors
        
      totalHeight = 40
      minimumHeight = Math.floor totalHeight / rowsCount
      verticalRemainder = totalHeight % rowsCount
      startY = 14
      
      for rowColors, rowIndex in colorRows
        colorHeight = minimumHeight
        colorHeight++ if rowIndex < verticalRemainder
        
        totalWidth = 192
        minimumWidth = Math.floor totalWidth / rowColors.length
        horizontalRemainder = totalWidth % rowColors.length
        startX = 23
        
        for color, colorIndex in rowColors
          colorWidth = minimumWidth
          colorWidth++ if colorIndex < horizontalRemainder
          
          for x in [0...colorWidth - 1]
            for y in [0...colorHeight - 1]
              index = ((y + startY) * @width + startX + x) * 4
              @topCanvasImageData.data[index] = color.r * 255
              @topCanvasImageData.data[index + 1] = color.g * 255
              @topCanvasImageData.data[index + 2] = color.b * 255
          
          startX += colorWidth
          
        startY += colorHeight
    
      @applyCanvases()
  
  infoStyle: ->
    return unless darkestColor = @darkestColor()
    
    color: "##{darkestColor.getHexString()}"
  
  lospecLogoStyle: -> @_lospecLogoStyle @brightestColor()
  lospecLogoHoverStyle: -> @_lospecLogoStyle @accentColor()
  
  _lospecLogoStyle: (color) ->
    return unless color
    
    backgroundColor: "##{color.getHexString()}"

  events: ->
    super(arguments...).concat
      'click .page': @onClickPage
      
  onClickPage: (event) ->
    return if $(event.target).closest('.lospec-link').length
    
    @paletteSelection = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing.PaletteSelection
    
    @paletteSelection.selectPalette @data()
