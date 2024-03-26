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
  osCursor.forceClass if largestDimension > 10 then 'grabbing' else 'none'
  
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
    osCursor.endClassForcing()

    newPosition = part.position()
    
    # See if the new position is inside the playfield.
    if newPosition and 0 < newPosition.x < Pinball.SceneManager.playfieldWidth and 0 < newPosition.z < Pinball.SceneManager.shortPlayfieldHeight
      # Snap new position to pixels.
      Pinball.CameraManager.snapShapeToPixelPosition part.shape(), newPosition
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
