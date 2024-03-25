AE = Artificial.Everywhere
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.EditorManager
  constructor: (@pinball) ->
    @hoveredPart = new ReactiveField null
    @selectedPart = new ReactiveField null
    @draggingPart = new ReactiveField null
    
    @dragCanvas = new ReactiveField false
  
  select: ->
    selectedPart = null
    
    if hoveredPart = @hoveredPart()
      selectedPart = hoveredPart if _.find Pinball.Part.getSelectablePartClasses(), (partClass) => hoveredPart instanceof partClass

    @selectedPart selectedPart
    
  addPart: (options) ->
    # Calculate target element's position in the playfield.
    elementOffset = $(options.element).offset()
    playfieldOffset = $('.pixelartacademy-pixeltosh-programs-pinball-interface-playfield').offset()
    scale = @pinball.os.display.scale()
    
    topLeftPosition = @pinball.cameraManager().transformWindowToPlayfield
      x: elementOffset.left - playfieldOffset.left
      y: elementOffset.top - playfieldOffset.top
    
    part = type: options.type
    
    # Add the node in the database.
    playfieldPartId = @_addPart part
    
    Tracker.autorun (computation) =>
      return unless part = @pinball.sceneManager().getPart playfieldPartId
      return unless shape = part.shape()
      computation.stop()
      
      pixelSize = Pinball.CameraManager.orthographicPixelSize
      
      startPosition =
        x: topLeftPosition.x + shape.bitmapOrigin.x * pixelSize
        y: topLeftPosition.y + shape.bitmapOrigin.y * pixelSize
      
      Pinball.CameraManager.snapShapeToPixelPosition shape, startPosition
      
      @startDrag part, {startPosition}

  startDrag: (part, options) ->
    return if @draggingPart() is part
    @draggingPart part
    
    osCursor = @pinball.os.cursor()
    osCursor.startGrabbing()
    startCoordinates = osCursor.coordinates()
    startPosition = options?.startPosition or part.data().position
    
    # Wire dragging handlers.
    $document = $(document)
    $interface = $('.pixelartacademy-pixeltosh-program-view').closest('.fatamorgana-interface')
    
    # Create a throttled delta update function to emulate a slow CPU.
    delay = if LOI.settings.graphics.slowCPUEmulation.value() then 75 else 0
    pixelSize = Pinball.CameraManager.orthographicPixelSize
    
    $interface.on 'pointermove.pixelartacademy-pixeltosh-programs-pinball-editormanager', _.throttle (event) =>
      return unless coordinates = osCursor.coordinates()
      
      part.setTemporaryPosition
        x: startPosition.x + (coordinates.x - startCoordinates.x) * pixelSize
        y: startPosition.y + (coordinates.y - startCoordinates.y) * pixelSize
    ,
      delay

    # Wire end of dragging on pointer up anywhere in the window.
    $document.on 'pointerup.pixelartacademy-pixeltosh-programs-pinball-editormanager', =>
      osCursor.endGrabbing()

      # Snap new position to pixels.
      newPosition = part.position()
      Pinball.CameraManager.snapShapeToPixelPosition part.shape(), newPosition
      
      # See if the new position is inside the playfield.
      if newPosition and 0 < newPosition.x < Pinball.SceneManager.playfieldWidth and 0 < newPosition.y < Pinball.SceneManager.shortPlayfieldHeight
        @_updatePart part, position: newPosition
        
        # Wait until the new position has updated on the document, before removing the temporary override.
        Tracker.autorun (computation) =>
          return unless EJSON.equals part.data().position, newPosition
          computation.stop()
          part.setTemporaryPosition null
          
      else
        @_removePart part
        @selectedPart null
        
      $interface.off '.pixelartacademy-pixeltosh-programs-pinball-editormanager'
      $document.off '.pixelartacademy-pixeltosh-programs-pinball-editormanager'
      
      @draggingPart null
      
  _addPart: (partData) ->
    projectId = @pinball.projectId()
    playfieldPartId = Random.id()
    
    PAA.Practice.Project.documents.update projectId,
      $set:
        "playfield.#{playfieldPartId}": partData
    
    playfieldPartId

  _updatePart: (part, difference) ->
    projectId = @pinball.projectId()
    partData = _.cloneDeep part.data()
    _.applyObjectDifference partData, difference
    
    PAA.Practice.Project.documents.update projectId,
      $set:
        "playfield.#{part.playfieldPartId}": partData
    
  _removePart: (part) ->
    projectId = @pinball.projectId()
    
    PAA.Practice.Project.documents.update projectId,
      $unset:
        "playfield.#{part.playfieldPartId}": true
