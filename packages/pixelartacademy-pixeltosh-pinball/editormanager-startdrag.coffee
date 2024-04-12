AE = Artificial.Everywhere
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

Pinball.EditorManager::startDrag = (part, options) ->
  return if @draggingPart()
  @draggingPart part
  
  osCursor = @pinball.os.cursor()
  
  # Show the grabbing cursor or none if the part is smaller than the hand.
  bitmap = part.bitmap()
  largestDimension = Math.max bitmap.bounds.width, bitmap.bounds.height
  cursorClass = if largestDimension > 15 then 'grabbing' else 'none'
  osCursor.requestClass cursorClass, @
  
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
      z: startPosition.z + (coordinates.y - startCoordinates.y) * pixelSize
  ,
    delay

  # Wire end of dragging on pointer up anywhere in the window.
  $document.on 'pointerup.pixelartacademy-pixeltosh-programs-pinball-editormanager', =>
    osCursor.endClassRequests @

    newPosition = part.position()
    
    # See if the new position is inside the playfield.
    if newPosition and 0 < newPosition.x < Pinball.SceneManager.playfieldWidth and 0 < newPosition.z < Pinball.SceneManager.shortPlayfieldDepth
      # Snap new position to pixels.
      rotationQuaternion = part.rotationQuaternion()
      Pinball.CameraManager.snapShapeToPixelPosition part.shape(), newPosition, rotationQuaternion
      @updatePart part, position: newPosition
      
      # Wait until the new position has updated on the document, before removing the temporary override.
      Tracker.autorun (computation) =>
        return unless EJSON.equals part.data().position, newPosition
        computation.stop()
        part.setTemporaryPosition null
        
    else
      @removePart part
      @selectedPart null
      
    $interface.off '.pixelartacademy-pixeltosh-programs-pinball-editormanager'
    $document.off '.pixelartacademy-pixeltosh-programs-pinball-editormanager'
    
    @draggingPart null
