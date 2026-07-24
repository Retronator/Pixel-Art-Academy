AE = Artificial.Everywhere
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Model = PAA.PixelPad.Apps.Drawing.Editor.Desktop.References.DisplayComponent.Reference.Model

class Model.CameraManager
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
      @_camera = Model.Helpers.createCamera THREE, camera, 1

      @camera @_camera
    
    # Update camera aspect ratio when canvas size changes.
    @reference.autorun =>
      return unless camera = @camera()
      return unless viewportSize = @reference.viewportSize()
      
      Model.Helpers.updateCameraAspectRatio camera, viewportSize.width / viewportSize.height
      @camera.updated()
      
    # Update camera properties from the reference.
    @reference.autorun =>
      return unless cameraData = @reference.data().displayOptions?.camera
      
      @_properties Model.Helpers.getCameraProperties cameraData

    # Update camera position when properties change.
    @reference.autorun =>
      return unless camera = @camera()
      properties = @_properties()
      
      Model.Helpers.applyCameraProperties camera, properties

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
