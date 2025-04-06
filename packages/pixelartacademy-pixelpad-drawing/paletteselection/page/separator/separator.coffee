AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.PaletteSelection.Page.Separator extends PAA.PixelPad.Apps.Drawing.PaletteSelection.Page
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.PaletteSelection.Page.Separator'
  @register @id()
  
  onCreated: ->
    super arguments...

    section = @data()
    
    for x in [0...@width]
      for y in [0...@height]
        index = (y * @width + x) * 4
        
        @topCanvasImageData.data[index] = section.color.r * 255
        @topCanvasImageData.data[index + 1] = section.color.g * 255
        @topCanvasImageData.data[index + 2] = section.color.b * 255
    
    @applyCanvases()
