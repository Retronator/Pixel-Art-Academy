LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

_boundingBox = new THREE.Box3

class Pinball.Interface.Parts extends LOI.View
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Parts'
  
  onCreated: ->
    super arguments...
    
    @os = @interface.parent
    @pinball = @os.getProgram Pinball
    
    @parts = for partClass in Pinball.Part.getSelectablePartClasses()
      new partClass @pinball
      
    @selectedPartChanged = new Tracker.Dependency
    
    @autorun (computation) =>
      return unless selectedPart = @selectedPart()
      selectedPart.data()
      selectedPart.position()
      
      # Let the physics engine update its bounding box.
      await _.waitForNextAnimationFrame()
      
      @selectedPartChanged.changed()
      
  onDestroyed: ->
    super arguments...
    
    part.destroy() for part in @parts
  
  bitmapImageOptions: ->
    part = @currentData()
    
    bitmap: part.bitmap
  
  hoveredPart: ->
    @pinball.editorManager()?.hoveredPart()
  
  selectedPart: ->
    @pinball.editorManager()?.selectedPart()
    
  selectionVisibleClass: ->
    'visible' if @selectedPart() and not @pinball.editorManager().editing()
    
  selectionStyle: ->
    # Depend on the selected part's changes.
    return unless selectedPart = @selectedPart()
    @selectedPartChanged.depend()

    # Get the bounding box from the physics object.
    return unless physicsObject = selectedPart.avatar.getPhysicsObject()
    physicsObject.getBoundingBox _boundingBox
    
    padding = 2
    pixelSize = Pinball.CameraManager.orthographicPixelSize
    
    left = Math.floor(_boundingBox.min.x / pixelSize) - padding
    right = Math.ceil(_boundingBox.max.x / pixelSize) + padding
    top = Math.floor(_boundingBox.min.z / pixelSize) - padding
    bottom = Math.ceil(_boundingBox.max.z / pixelSize) + padding
    
    width = right - left
    height = bottom - top
    width++ if width % 2
    height++ if height % 2
    
    left: "#{left}rem"
    top: "#{top}rem"
    width: "#{width}rem"
    height: "#{height}rem"
    
  events: ->
    super(arguments...).concat
      'pointermove': @onPointerMove
      'pointerdown .part': @onPointerDownPart
      'pointerdown .drag-area': @onPointerDownDragArea
      'pointerdown .rotate-area': @onPointerDownRotateArea
      'click .flip-button': @onClickFlipButton
      
  onPointerMove: (event) ->
    @pinball.mouse().onMouseMove event
    
  onPointerDownPart: (event) ->
    part = @currentData()
    @pinball.editorManager().addPart
      type: part.id()
      element: event.target
  
  onPointerDownDragArea: (event) ->
    @pinball.editorManager().startDrag @selectedPart()
    
  onPointerDownRotateArea: (event) ->
    @pinball.editorManager().startRotate @selectedPart()
  
  onClickFlipButton: (event) ->
    flip = @interface.getOperator Pinball.Interface.Actions.Flip
    flip.execute()
