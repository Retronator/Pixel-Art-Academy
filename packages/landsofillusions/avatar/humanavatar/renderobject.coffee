AS = Artificial.Spectrum
LOI = LandsOfIllusions

class LOI.HumanAvatar.RenderObject extends AS.RenderObject
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
    ]

    bodyBottom = [-10.2, -10.1, -10.3]
    bodyTop = [6, 5.8, 5.5]

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
      if sideAngle < 0
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

        textureContext.setTransform 1, 0, 0, 1, 100 * sideIndex, 0

        renderer.drawToContext textureContext, _.extend
          rootPart: renderer.options.part
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

        normalContext.setTransform 1, 0, 0, 1, 100 * sideIndex, 0

        renderer.drawToContext normalContext, _.extend
          rootPart: renderer.options.part
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

      @debugTextureDataUrl textureScaledCanvas.toDataURL()

  destroy: ->
    super arguments...

    renderer.stop() for renderer in @textureRendeders()
    animatedMesh.destroy() for side, animatedMesh of @animatedMeshes

    @_textureUpdateAutorun.stop()

  update: (appTime) ->
    if @_targetAngle?
      angleDelta = @_angleChangeSpeed * appTime.elapsedAppTime
      @_angleChange += Math.abs angleDelta
      @currentAngle += angleDelta

      if @_angleChange > @_totalAngleChange
        @currentAngle = @_targetAngle
        @_targetAngle = null

    # Calculate angle relative to camera position.
    camera = LOI.adventure.world.cameraManager().camera()
    directionToCamera = new THREE.Vector3().subVectors camera.position, @position
    cameraAngle = LOI.Engine.RenderingSides.getAngleForDirection directionToCamera

    side = LOI.Engine.RenderingSides.getSideForAngle @currentAngle - cameraAngle
    @setCurrentSide side unless side is @currentSide

    for side, animatedMesh of @animatedMeshes
      updateData = side is @currentSide
      animatedMesh.update appTime, updateData

  setAnimation: (animationName) ->
    animatedMesh.currentAnimationName animationName for side, animatedMesh of @animatedMeshes

  faceDirection: (direction) ->
    # Calculate turning rotation from the angle that the side implies so the turning reaction appears immediate.
    @currentAngle = LOI.Engine.RenderingSides.angles[@currentSide]
    @_targetAngle = LOI.Engine.RenderingSides.getAngleForDirection direction
    @_angleChange = 0
    @_totalAngleChange = _.angleDistance @_targetAngle, @currentAngle
    @_angleChangeSpeed = 8 * Math.sign _.angleDifference @_targetAngle, @currentAngle

  setCurrentSide: (side) ->
    previousAnimatedMesh = @animatedMeshes[@currentSide]
    previousAnimatedMesh.visible = false

    @currentSide = side
    @animatedMeshes[@currentSide].visible = true
    @animatedMeshes[@currentSide].syncAnimationTo previousAnimatedMesh
