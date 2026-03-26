AB = Artificial.Babel
AM = Artificial.Mirage
AP = Artificial.Program
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PADB = PixelArtDatabase

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.References.DisplayComponent.Reference.SceneObject extends PAA.PixelPad.Apps.Drawing.Editor.Desktop.References.DisplayComponent.Reference
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.References.DisplayComponent.Reference.SceneObject'
  @register @id()
  
  constructor: ->
    super arguments...
    
    # Scene object references can't be resized.
    @resizingBorder = 0

  displaySize: (scale) ->
    return unless imageSize = @imageSize()

    reference = @data()
    scale = reference.displayOptions?.scale or 1
    
    width: imageSize.width * scale
    height: imageSize.height * scale

  referenceStyle: ->
    return display: 'none' unless displaySize = @displaySize()

    style = super arguments...
    style.width = "#{displaySize.width}rem"
    style.height = "#{displaySize.height}rem"
    style
  
  customShadowClass: ->
    reference = @data()
    'custom-shadow' if reference.displayOptions?.shadow
