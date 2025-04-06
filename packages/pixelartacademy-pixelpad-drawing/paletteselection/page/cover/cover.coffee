AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.PaletteSelection.Page.Cover extends PAA.PixelPad.Apps.Drawing.PaletteSelection.Page
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.PaletteSelection.Page.Cover'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @paletteSelection = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing.PaletteSelection
    
    @autorun (computation) =>
      return unless palette = LOI.palette()
      computation.stop()
      
      leftColor = new THREE.Color palette.color LOI.Assets.Palette.Atari2600.hues.gray, 8
      rightColor = new THREE.Color palette.color LOI.Assets.Palette.Atari2600.hues.blue, 3
      
      for x in [0...@width]
        for y in [0...@height]
          index = (y * @width + x) * 4
          
          color = if x < 60 then leftColor else rightColor
          
          @topCanvasImageData.data[index] = color.r * 255
          @topCanvasImageData.data[index + 1] = color.g * 255
          @topCanvasImageData.data[index + 2] = color.b * 255

      @applyCanvases()

  events: ->
    super(arguments...).concat
      'click .menu-item': @onClickMenuItem
  
  onClickMenuItem: (event) ->
    section = @currentData()
    
    @paletteSelection.goToPage section.separatorPageIndex
