AS = Artificial.Spectrum
LOI = LandsOfIllusions

class LOI.HumanAvatar.RenderObject extends AS.RenderObject
  @debugLandmarks = false
  @debugMapping = false

  constructor: (@humanAvatar) ->
    super arguments...

    @debugTextureDataUrl = new ReactiveField null

    @textureRenderers = {}
    @animatedMeshes = {}
    
    @currentAngle = 0
    @currentSide = LOI.Engine.RenderingSides.Keys.Front

    @textureSides = [
      LOI.Engine.RenderingSides.Keys.Front
      LOI.Engine.RenderingSides.Keys.FrontLeft
      LOI.Engine.RenderingSides.Keys.Left
      LOI.Engine.RenderingSides.Keys.BackLeft
      LOI.Engine.RenderingSides.Keys.Back
      LOI.Engine.RenderingSides.Keys.BackRight
      LOI.Engine.RenderingSides.Keys.Right
      LOI.Engine.RenderingSides.Keys.FrontRight
    ]

    bodyBottom = [-10.2, -10, -10.3, -9.9, -10.2]
    bodyTop = [6, 5.8, 5.5, 5.8, 6]

    @_cameraPosition = new THREE.Vector3
    @_cameraRotation = new THREE.Quaternion
    @_cameraScale = new THREE.Vector3
    @_cameraEuler = new THREE.Euler
    @_cameraDirection = new THREE.Vector3

    for side in @textureSides
      do (side) =>
        # Create avatar renderers for drawing the textures. They need to be
        # created inside a computation so they get recreated when data changes.
        textureRenderer = new ComputedField =>
          new LOI.Character.Avatar.Renderers.HumanAvatar
            humanAvatar: @humanAvatar
            renderTexture: true
            viewingAngle: => LOI.Engine.RenderingSides.angles[side]
          ,
            true
        ,
          true

        @textureRenderers[side] = textureRenderer

    for side, sideAngle of LOI.Engine.RenderingSides.angles
      # Create the animated mesh.
      if sideAngle > 0
        sideName = LOI.Engine.RenderingSides.mirrorSides[side]

      else
        sideName = side

      animatedMesh = new AS.AnimatedMesh
        dataUrl: "/landsofillusions/avatar/#{_.toLower sideName}.json"
        dataFPS: 60
        playbackFPS: 8
        castShadow: true
        receiveShadow: true
        material: new LOI.Engine.SpriteMaterial

      animatedMesh.blendTime 0.2
      animatedMesh.currentAnimationName 'Idle'

      sideIndex = @textureSides.indexOf sideName
      bodyHeight = bodyTop[sideIndex] - bodyBottom[sideIndex]
      targetHeight = 1.8 # meters
      scale = targetHeight / bodyHeight

      animatedMesh.scale.multiplyScalar scale
      animatedMesh.position.y = -bodyBottom[sideIndex] * scale
      animatedMesh.scale.x *= -1 if sideAngle < 0
      animatedMesh.visible = false unless side is @currentSide

      @add animatedMesh

      @animatedMeshes[side] = animatedMesh

    # Create and automatically update textures.
    textureCanvas = $('<canvas>')[0]
    textureCanvas.width = 1024
    textureCanvas.height = 128
    textureContext = textureCanvas.getContext '2d'

    normalCanvas = $('<canvas>')[0]
    normalCanvas.width = 1024
    normalCanvas.height = 128
    normalContext = normalCanvas.getContext '2d'

    @_textureUpdateAutorun = Tracker.autorun (computation) =>
      # Render palette color map.
      textureContext.setTransform 1, 0, 0, 1, 0, 0
      textureContext.clearRect 0, 0, textureCanvas.width, textureCanvas.height

      textureContext.save()

      for side, sideIndex in @textureSides
        continue unless renderer = @textureRenderers[side]()

        renderer.drawToContext textureContext, _.extend
          rootPart: renderer.options.part
          textureOffset: 100 * sideIndex, 0
        ,
          renderPaletteData: true

        textureContext.restore()

      textureScaledCanvas = AS.Hqx.scale textureCanvas, 4, AS.Hqx.Modes.Default, false

      texture = new THREE.CanvasTexture textureScaledCanvas
      texture.magFilter = THREE.NearestFilter
      texture.minFilter = THREE.NearestFilter

      # Render normal map.
      normalContext.setTransform 1, 0, 0, 1, 0, 0
      normalContext.clearRect 0, 0, normalCanvas.width, normalCanvas.height

      normalContext.save()

      for side, sideIndex in @textureSides
        continue unless renderer = @textureRenderers[side]()

        renderer.drawToContext normalContext, _.extend
          rootPart: renderer.options.part
          textureOffset: 100 * sideIndex, 0
        ,
          renderNormalData: true

        normalContext.restore()

      normalImageData = normalContext.getImageData 0, 0, normalCanvas.width, normalCanvas.height
      AS.ImageDataHelpers.expandPixels normalImageData, 1
      normalContext.putImageData normalImageData, 0, 0

      normalScaledCanvas = AS.Hqx.scale normalCanvas, 4, AS.Hqx.Modes.Default, true

      normalMap = new THREE.CanvasTexture normalScaledCanvas

      # We update the map (via texture field) and normal map fields
      # on material so that appropriate shader defines get turned on.
      for side, animatedMesh of @animatedMeshes
        animatedMesh.texture texture
        animatedMesh.options.material.normalMap = normalMap
        animatedMesh.options.material.needsUpdate = true

        # HACK: We also manually have to update the values of uniforms, to actually change the texture.
        animatedMesh.options.material.uniforms.map.value = texture
        animatedMesh.options.material.uniforms.normalMap.value = normalMap

      debugCanvas = $('<canvas>')[0]
      debugScale = 8
      debugCanvas.width = 1024 * debugScale
      debugCanvas.height = 128 * debugScale
      debugContext = debugCanvas.getContext '2d'
      debugContext.imageSmoothingEnabled = false
      debugContext.drawImage textureCanvas, 0, 0, debugCanvas.width, debugCanvas.height
      debugContext.fillStyle = 'white'
      debugContext.lineWidth = 1 / debugScale

      for side, sideIndex in @textureSides
        continue unless renderer = @textureRenderers[side]()

        debugContext.setTransform debugScale, 0, 0, debugScale, 100 * sideIndex * debugScale, 0

        if @constructor.debugLandmarks
          for landmark in renderer.bodyRenderer.landmarks() when landmark.regionId
            debugContext.fillRect landmark.x + 0.25, landmark.y + 0.25, 0.5, 0.5

        if @constructor.debugMapping
          for articleRenderer in renderer.outfitRenderer.renderers()
            for articlePartRenderer in articleRenderer.renderers()
              for mappedShapeRenderer in articlePartRenderer.renderers()
                continue unless delaunay = mappedShapeRenderer.debugDelaunay()

                randomHue = _.random 360

                # Stroke all the triangles.
                debugContext.strokeStyle = "hsl(#{randomHue}, 50%, 50%)"
                debugContext.beginPath()

                for triangleIndex in [0...delaunay.triangles.length / 3]
                  coordinateIndices = for offset in [0..2]
                    delaunay.triangles[triangleIndex * 3 + offset]

                  getCoordinate = (index, offset) =>
                    delaunay.coords[coordinateIndices[index] * 2 + offset] + 0.5 - 0.5 / debugScale

                  debugContext.moveTo getCoordinate(2, 0), getCoordinate(2, 1)

                  for offset in [0..2]
                    debugContext.lineTo getCoordinate(offset, 0), getCoordinate(offset, 1)

                debugContext.stroke()

                # Stroke the outside hull.
                debugContext.strokeStyle = "hsl(#{randomHue}, 100%, 50%)"
                debugContext.beginPath()

                getHullCoordinate = (index, offset) =>
                  delaunay.coords[index * 2 + offset] + 0.5 - 0.5 / debugScale

                lastHullVertex = _.last delaunay.hull
                debugContext.moveTo getHullCoordinate(lastHullVertex, 0), getHullCoordinate(lastHullVertex, 1)

                for hullIndex in delaunay.hull
                  debugContext.lineTo getHullCoordinate(hullIndex, 0), getHullCoordinate(hullIndex, 1)

                debugContext.stroke()

      @debugTextureDataUrl debugCanvas.toDataURL()

  destroy: ->
    super arguments...

    renderer.stop() for renderer in @textureRendeders()
    animatedMesh.destroy() for side, animatedMesh of @animatedMeshes

    @_textureUpdateAutorun.stop()

  update: (appTime, options = {}) ->
    if @_targetAngle?
      angleDelta = @_angleChangeSpeed * appTime.elapsedAppTime
      @_angleChange += Math.abs angleDelta
      @currentAngle += angleDelta

      if @_angleChange > @_totalAngleChange
        @currentAngle = @_targetAngle
        @_targetAngle = null

    # Project the direction and calculate angle in screen coordinates.
    camera = options.camera or LOI.adventure.world.cameraManager().camera()
    camera.matrix.decompose @_cameraPosition, @_cameraRotation, @_cameraScale

    @_cameraDirection.subVectors @_cameraPosition, @position
    cameraAngle = LOI.Engine.RenderingSides.getAngleForDirection @_cameraDirection

    # Get the side based on how much the camera is away from where the character is facing.
    side = LOI.Engine.RenderingSides.getSideForAngle cameraAngle - @currentAngle
    @setCurrentSide side unless side is @currentSide

    for side, animatedMesh of @animatedMeshes
      updateData = side is @currentSide
      animatedMesh.update appTime, updateData

    # Avatar sprite should always face the camera.
    @_cameraEuler.setFromQuaternion @_cameraRotation, "YXZ"
    @rotation.y = @_cameraEuler.y

  setAnimation: (animationName) ->
    animatedMesh.currentAnimationName animationName for side, animatedMesh of @animatedMeshes

  faceDirection: (direction) ->
    @_targetAngle = LOI.Engine.RenderingSides.getAngleForDirection direction
    @_angleChange = 0
    @_totalAngleChange = _.angleDistance @_targetAngle, @currentAngle
    @_angleChangeSpeed = 4 * Math.sign _.angleDifference @_targetAngle, @currentAngle

  setCurrentSide: (side) ->
    previousAnimatedMesh = @animatedMeshes[@currentSide]
    previousAnimatedMesh.visible = false

    @currentSide = side
    @animatedMeshes[@currentSide].visible = true
    @animatedMeshes[@currentSide].syncAnimationTo previousAnimatedMesh
