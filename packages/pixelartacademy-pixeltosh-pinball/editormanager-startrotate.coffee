AE = Artificial.Everywhere
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

_snappingAngles = [
  -Math.PI
  Math.atan2 -1, -2
  Math.atan2 -1, -1
  Math.atan2 -2, -1
  -Math.PI / 2
  Math.atan2 -2, 1
  Math.atan2 -1, 1
  Math.atan2 -1, 2
  0
  Math.atan2 1, 2
  Math.atan2 1, 1
  Math.atan2 2, 1
  Math.PI / 2
  Math.atan2 2, -1
  Math.atan2 1, -1
  Math.atan2 1, -2
  Math.PI
]

Pinball.EditorManager::startRotate = (part) ->
  return if @rotatingPart()
  @rotatingPart part
  
  rotationAxis = @pinball.cameraManager().transformPlayfieldToDisplay part.position()

  # Adjust rotation axis by menu height to bring it to the OS coordinate system.
  rotationAxis.y += PAA.Pixeltosh.OS.Interface.menuHeight
  
  osCursor = @pinball.os.cursor()
  startCoordinates = osCursor.coordinates()
  startCursorAngle = Math.atan2 startCoordinates.y - rotationAxis.y, startCoordinates.x - rotationAxis.x
  startRotationAngle = part.rotationAngle()
  
  # Wire rotating handlers.
  $document = $(document)
  $interface = $('.pixelartacademy-pixeltosh-program-view').closest('.fatamorgana-interface')
  
  updateAngle = (event) =>
    return unless coordinates = osCursor.coordinates()
    
    cursorAngle = Math.atan2 coordinates.y - rotationAxis.y, coordinates.x - rotationAxis.x
    
    cursorClass = switch
      when -Math.PI * 3 / 4 < cursorAngle > Math.PI * 3 / 4 then 'w-rotate'
      when cursorAngle > Math.PI / 4 then 's-rotate'
      when cursorAngle < -Math.PI / 4 then 'n-rotate'
      else 'e-rotate'
      
    osCursor.requestClass cursorClass, @
    
    newAngle = _.normalizeAngle startRotationAngle + (startCursorAngle - cursorAngle)
    
    # Apply angle snapping.
    unless event.shiftKey
      minDistance = Number.POSITIVE_INFINITY
      snappedAngle = null
      
      for snappingAngle in _snappingAngles
        angleDistance = _.angleDistance newAngle, snappingAngle
        
        if angleDistance < minDistance
          minDistance = angleDistance
          snappedAngle = snappingAngle
      
      newAngle = snappedAngle
    
    part.setTemporaryRotationAngle newAngle
  
  # Create a throttled delta update function to emulate a slow CPU.
  delay = if LOI.settings.graphics.slowCPUEmulation.value() then 75 else 0
  
  $interface.on 'pointermove.pixelartacademy-pixeltosh-programs-pinball-editormanager', _.throttle (event) =>
    updateAngle event
  ,
    delay
  
  $document.on 'keydown.pixelartacademy-pixeltosh-programs-pinball-editormanager', (event) =>
    updateAngle event
    
  $document.on 'keyup.pixelartacademy-pixeltosh-programs-pinball-editormanager', (event) =>
    updateAngle event

  # Wire end of rotating on pointer up anywhere in the window.
  $document.on 'pointerup.pixelartacademy-pixeltosh-programs-pinball-editormanager', =>
    osCursor.endClassRequests @
    
    newRotationAngle = part.rotationAngle()
    @updatePart part, rotationAngle: newRotationAngle
    
    # Wait until the new position has updated on the document, before removing the temporary override.
    Tracker.autorun (computation) =>
      return unless EJSON.equals part.data().rotationAngle, newRotationAngle
      computation.stop()
      part.setTemporaryRotationAngle null
      
    $interface.off '.pixelartacademy-pixeltosh-programs-pinball-editormanager'
    $document.off '.pixelartacademy-pixeltosh-programs-pinball-editormanager'
    
    @rotatingPart null
