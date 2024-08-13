LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

_boundingBox = new THREE.Box3

class Pinball.Interface.Playfield extends LOI.View
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Playfield'
  
  @minSelectionSize = 16
  
  onCreated: ->
    super arguments...
    
    @os = @interface.parent
    @pinball = @os.getProgram Pinball
    
    @selectedPart = new ComputedField =>
      @pinball.editorManager()?.selectedPart()
    
    @selectedPartChanged = new Tracker.Dependency
    
    @autorun (computation) =>
      return unless selectedPart = @selectedPart()
      return unless selectedPart.ready()

      # Update when data or position change.
      selectedPart.data()
      selectedPart.position()
      
      # Let the physics engine update its bounding box.
      await _.waitForNextAnimationFrame()
      
      @selectedPartChanged.changed()

  onRendered: ->
    super arguments...
    
    @$('.pixelartacademy-pixeltosh-programs-pinball-interface-playfield').append @pinball.rendererManager().renderer.domElement

  showOverlay: ->
    @pinball.gameManager()?.mode() isnt Pinball.GameManager.Modes.Play

  selectionVisibleClass: ->
    return unless selectedPart = @selectedPart()
    'visible' if selectedPart.constructor.placeable()
    
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
    
    if width < @constructor.minSelectionSize
      left += (width - @constructor.minSelectionSize) / 2
      width = @constructor.minSelectionSize
      
    if height < @constructor.minSelectionSize
      top += (height - @constructor.minSelectionSize) / 2
      height = @constructor.minSelectionSize
    
    left: "#{left}rem"
    top: "#{top}rem"
    width: "#{width}rem"
    height: "#{height}rem"
    
  partVisibleClass: ->
    # Only show selected part when dragging it over the parts.
    return unless selectedPart = @selectedPart()
    
    'visible' if selectedPart.position()?.x > Pinball.SceneManager.playfieldWidth
  
  controlsVisibleClass: ->
    'visible' unless @pinball.editorManager()?.editing()
    
  selectedPartBitmapImageOptions: ->
    bitmap: => @selectedPart()?.bitmap()
    
  events: ->
    super(arguments...).concat
      'pointerdown canvas': @onPointerDownCanvas
      'pointermove': @onPointerMove
      'pointerleave .pixelartacademy-pixeltosh-programs-pinball-interface-playfield': @onPointerLeavePlayfield
      'wheel': @onPointerWheel
      'pointerdown .drag-area': @onPointerDownDragArea
      'pointerdown .rotate-area': @onPointerDownRotateArea
      'click .flip-button': @onClickFlipButton
      
  onPointerDownCanvas: (event) ->
    # Prevent browser select/dragging behavior.
    event.preventDefault()

    cameraManager = @pinball.cameraManager()
    
    switch cameraManager.displayType()
      when Pinball.CameraManager.DisplayTypes.Orthographic
        # Prevent selection in play mode.
        return if @pinball.gameManager()?.mode() is Pinball.GameManager.Modes.Play

        editorManager = @pinball.editorManager()
        editorManager.select()
        
        selectedPart = editorManager.selectedPart()

        if selectedPart?.constructor.placeable()
          # See if the player releases the mouse button, otherwise also start dragging.
          $document = $(document)
          
          stopListening = =>
            $document.off '.pixelartacademy-pixeltosh-programs-pinball-interface-playfield'
            
          $document.on 'pointerup.pixelartacademy-pixeltosh-programs-pinball-interface-playfield', =>
            Meteor.clearTimeout @_dragTimeout
            stopListening()
            
          $document.on 'pointermove.pixelartacademy-pixeltosh-programs-pinball-interface-playfield', =>
            Meteor.clearTimeout @_dragTimeout
            stopListening()
            editorManager.startDrag selectedPart
    
      when Pinball.CameraManager.DisplayTypes.Perspective
        cameraManager.startRotateCamera event.coordinates

  onPointerMove: (event) ->
    @pinball.mouse().onMouseMove event

  onPointerLeavePlayfield: (event) ->
    @pinball.mouse().onMouseLeave event

  onPointerWheel: (event) ->
    @pinball.cameraManager().changeDistanceByFactor 1.005 ** event.originalEvent.deltaY
  
  onPointerDownDragArea: (event) ->
    @pinball.editorManager().startDrag @selectedPart()
  
  onPointerDownRotateArea: (event) ->
    @pinball.editorManager().startRotate @selectedPart()
  
  onClickFlipButton: (event) ->
    flip = @interface.getOperator Pinball.Interface.Actions.Flip
    flip.execute()
