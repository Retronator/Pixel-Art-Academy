AE = Artificial.Everywhere
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.References.DisplayComponent.Reference.Model.CameraManager
  @fullRotationDelta = 50 # display pixels

  constructor: (@reference) ->
    @_camera = new THREE.PerspectiveCamera 60, 1, 0.01, 100
    @camera = new AE.ReactiveWrapper @_camera
    
    @_properties = new ReactiveField
      azimuthalAngle: 0
      polarAngle: 0
      radialDistance: 1
    
    # Update camera field of view from the reference.
    @reference.autorun =>
      @_camera.fov = @reference.data().displayOptions?.camera?.fieldOfView or 60
      @_camera.updateProjectionMatrix()
      @camera.updated()
    
    # Update camera aspect ratio when canvas size changes.
    @reference.autorun =>
      return unless viewportSize = @reference.viewportSize()
      
      @_camera.aspect = viewportSize.width / viewportSize.height
      @_camera.updateProjectionMatrix()
      @camera.updated()
      
    # Update camera properties from the reference.
    @reference.autorun =>
      return unless cameraData = @reference.data().displayOptions?.camera
      
      properties = Tracker.nonreactive => @_properties()
      properties.azimuthalAngle = cameraData.azimuthalAngle ? 0
      properties.polarAngle = cameraData.polarAngle ? 0
      properties.radialDistance = cameraData.radialDistance ? 1
      @_properties properties

    # Update camera position when properties change.
    @reference.autorun =>
      properties = @_properties()
      
      @_camera.position.setFromSphericalCoords properties.radialDistance, properties.polarAngle, properties.azimuthalAngle
      
      # Update rotation to look at the center.
      @_camera.rotation.set -Math.PI / 2 + properties.polarAngle, properties.azimuthalAngle, 0, 'YXZ'

      @camera.updated()

  startRotateCamera: (event) ->
    # Dragging of blueprint needs to be handled in display coordinates since the canvas ones should technically stay
    # the same (the whole point is for the same canvas coordinate to stay under the mouse as we move it around).
    startClientCoordinatesX = event.clientX
    startClientCoordinatesY = event.clientY
    
    startProperties = _.clone @_properties()
    
    # Wire movement of the mouse anywhere in the window.
    $(document).on 'pointermove.pixelartacademy-pixelpad-apps-drawing-editor-desktop-references-displaycomponent-reference-model-cameramanager', (event) =>
      scale = @reference.display.scale()
      
      dragDeltaX = (startClientCoordinatesX - event.clientX) / scale / @constructor.fullRotationDelta
      dragDeltaY = (startClientCoordinatesY - event.clientY) / scale / @constructor.fullRotationDelta

      # Only react to mouse coordinate changes.
      properties = @_properties()
      
      properties.azimuthalAngle = startProperties.azimuthalAngle + dragDeltaX * Math.PI * 2
      properties.polarAngle = startProperties.polarAngle + dragDeltaY * Math.PI * 2

      @_properties properties

    # Wire end of dragging on pointer up anywhere in the window.
    $(document).on 'pointerup.pixelartacademy-pixelpad-apps-drawing-editor-desktop-references-displaycomponent-reference-model-cameramanager', =>
      $(document).off '.pixelartacademy-pixelpad-apps-drawing-editor-desktop-references-displaycomponent-reference-model-cameramanager'
      
      properties = @_properties()
      
      @reference.changeDisplayOptions
        camera:
          azimuthalAngle: properties.azimuthalAngle,
          polarAngle: properties.polarAngle

  changeDistanceByFactor: (factor) ->
    properties = @_properties()
    properties.radialDistance = _.clamp properties.radialDistance * factor, 0.1, 10
    @_properties properties
    
    @_debouncedRadialDistanceUpdate ?= _.debounce (radialDistance) =>
      @reference.changeDisplayOptions camera: {radialDistance}
    ,
      1000
    
    @_debouncedRadialDistanceUpdate properties.radialDistance
