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
      new partClass @pinball
      
  onDestroyed: ->
    super arguments...
    
    part.destroy() for part in @parts
  
  bitmapImageOptions: ->
    part = @currentData()
    
    bitmap: part.bitmap
    
  events: ->
    super(arguments...).concat
      'pointerdown .part': @onPointerDownPart
    
  onPointerDownPart: (event) ->
    part = @currentData()
    @pinball.editorManager().addPart
      type: part.id()
      element: event.target
