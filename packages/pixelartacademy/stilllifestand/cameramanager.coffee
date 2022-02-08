AE = Artificial.Everywhere
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StillLifeStand.CameraManager
  constructor: (@stillLifeStand) ->
    @_camera = new THREE.PerspectiveCamera 60, 1, 0.01, 1000
    @_camera.layers.set LOI.Engine.RenderLayers.FinalRender
    @camera = new AE.ReactiveWrapper @_camera

    @_properties = new ReactiveField
      azimuthalAngle: AR.Degrees 90
      polarAngle: AR.Degrees 80
      radialDistance: 2

    # Update camera aspect ratio when canvas size changes.
    @stillLifeStand.autorun =>
      viewport = LOI.adventure.interface.display.viewport()

      width = viewport.viewportBounds.width()
      height = viewport.viewportBounds.height()

      return unless width and height

      @_camera.aspect = width / height
      @_camera.updateProjectionMatrix()
      @camera.updated()

    # Update camera position when properties change.
    @stillLifeStand.autorun =>
      properties = @_properties()
      r = properties.radialDistance
      ɸ = properties.azimuthalAngle
      θ = properties.polarAngle

      @_camera.position.copy
        x: r * Math.sin(θ) * Math.cos(ɸ)
        y: r * Math.cos(θ)
        z: r * Math.sin(θ) * Math.sin(ɸ)

      # Update rotation to look at the center.
      @_camera.rotation.set -Math.PI / 2 + θ, Math.PI / 2 - ɸ, 0, 'YXZ'

      @camera.updated()

    @rotatingCamera = new ReactiveField false
    @stillLifeStand.autorun =>
      return unless @rotatingCamera()
      return unless newViewportCoordinates = @stillLifeStand.mouse().viewportCoordinates()

      dragDelta =
        x: @_rotateCameraStartViewportCoordinates.x - newViewportCoordinates.x
        y: @_rotateCameraStartViewportCoordinates.y - newViewportCoordinates.y

      # Only react to mouse coordinate changes.
      Tracker.nonreactive =>
        oldProperties = @_properties()

        newProperties =
          azimuthalAngle: @_rotateCameraStartProperties.azimuthalAngle - dragDelta.x * Math.PI
          polarAngle: _.clamp @_rotateCameraStartProperties.polarAngle - dragDelta.y * Math.PI * 0.5, 0, Math.PI
          radialDistance: oldProperties.radialDistance

        @_properties newProperties

  startRotateCamera: ->
    # Dragging of blueprint needs to be handled in display coordinates since the canvas ones should technically stay
    # the same (the whole point is for the same canvas coordinate to stay under the mouse as we move it around).
    @_rotateCameraStartViewportCoordinates = @stillLifeStand.mouse().viewportCoordinates()
    @_rotateCameraStartProperties = @_properties()
    @rotatingCamera true

    # Wire end of dragging on mouse up anywhere in the window.
    $(document).on 'mouseup.pixelartacademy-stilllifestand-cameramanager', =>
      $(document).off '.pixelartacademy-stilllifestand-cameramanager'

      @rotatingCamera false

  changeDistanceByFactor: (factor) ->
    properties = @_properties()
    properties.radialDistance = _.clamp properties.radialDistance * factor, 0.1, 10
    @_properties properties
