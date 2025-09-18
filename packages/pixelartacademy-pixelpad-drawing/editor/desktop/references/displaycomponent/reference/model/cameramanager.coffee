AE = Artificial.Everywhere
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.References.DisplayComponent.Reference.Model.CameraManager
  @fullRotationDelta = 50 # display pixels

  constructor: (@reference) ->
    @camera = new AE.ReactiveWrapper null
    
    @_properties = new ReactiveField
      azimuthalAngle: 0
      polarAngle: 0
      radialDistance: 1
    
    # Update camera type and field of view from the reference.
    @reference.autorun =>
      camera = @reference.data().displayOptions?.camera
      zNear = camera?.zNear or 0.01
      zFar = camera?.zFar or 100
      
      if fieldOfView = camera?.fieldOfView
        @_camera = new THREE.PerspectiveCamera fieldOfView, 1, zNear, zFar
        
      else if frustum = camera?.frustum
        left = frustum.left or -frustum.width / 2
        right = frustum.right or frustum.width / 2
        top = frustum.top or frustum.height / 2
        bottom = frustum.bottom or -frustum.height / 2
        @_camera = new THREE.OrthographicCamera left, right, top, bottom, zNear, zFar
        
      else
        @_camera = null

      @camera @_camera
    
    # Update camera aspect ratio when canvas size changes.
    @reference.autorun =>
      return unless camera = @camera()
      return unless viewportSize = @reference.viewportSize()
      
      camera.aspect = viewportSize.width / viewportSize.height
      camera.updateProjectionMatrix()
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
      return unless camera = @camera()
      properties = @_properties()
      
      camera.position.setFromSphericalCoords properties.radialDistance, properties.polarAngle, properties.azimuthalAngle
      
      # Update rotation to look at the center.
      camera.rotation.set -Math.PI / 2 + properties.polarAngle, properties.azimuthalAngle, 0, 'YXZ'

      @camera.updated()

  startRotateCamera: (event) ->
    startClientCoordinatesX = event.clientX
    startClientCoordinatesY = event.clientY
    
    startProperties = _.clone @_properties()
    
    # Wire movement of the mouse anywhere in the window.
    $(document).on 'pointermove.pixelartacademy-pixelpad-apps-drawing-editor-desktop-references-displaycomponent-reference-model-cameramanager', (event) =>
      scale = @reference.display.scale()
      
      dragDeltaX = (event.clientX - startClientCoordinatesX) / scale / @constructor.fullRotationDelta
      dragDeltaY = (event.clientY - startClientCoordinatesY)  / scale / @constructor.fullRotationDelta

      # Only react to mouse coordinate changes.
      properties = @_properties()
      
      properties.azimuthalAngle = startProperties.azimuthalAngle - dragDeltaX * Math.PI * 2
      properties.polarAngle = startProperties.polarAngle - dragDeltaY * Math.PI * 2

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
