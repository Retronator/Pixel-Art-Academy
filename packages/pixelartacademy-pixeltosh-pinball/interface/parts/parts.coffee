LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.Parts extends LOI.View
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Parts'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @os = @interface.parent
    @pinball = @os.getProgram Pinball
    
    @parts = for partClass in Pinball.Part.getPlaceablePartClasses()
      part = new partClass @pinball
      part.avatar.initializeShape()
      part
      
  onDestroyed: ->
    super arguments...
    
    part.destroy() for part in @parts
  
  bitmapImageOptions: ->
    part = @currentData()
    
    bitmap: part.bitmap
    autoCrop: true
    
  events: ->
    super(arguments...).concat
      'pointerdown .part .image': @onPointerDownPartImage
    
  onPointerDownPartImage: (event) ->
    part = @currentData()
    
    # Don't allow adding invalid parts.
    return unless part.shape()
    
    @pinball.editorManager().addPart
      type: part.id()
      element: event.currentTarget
