AS = Artificial.Spectrum
LOI = LandsOfIllusions

class LOI.HumanAvatar.RenderObject extends AS.RenderObject
  @debugLandmarks = false
  @debugMapping = false

  constructor: (@humanAvatar) ->
    super arguments...

    @parentItem = @humanAvatar

    @debugTextureDataUrl = new ReactiveField null

    @animatedMeshes = {}
    
    @currentAngle = 0
    @currentSide = LOI.Engine.RenderingSides.Keys.Front

    bodyBottom = [-10.2, -10, -10.3, -9.9, -10.2]
    bodyTop = [6, 5.8, 5.5, 5.8, 6]

    @_rotationEuler = new THREE.Euler
    @_cameraPosition = new THREE.Vector3
    @_cameraRotation = new THREE.Quaternion
    @_cameraScale = new THREE.Vector3
    @_cameraEuler = new THREE.Euler
    @_cameraDirection = new THREE.Vector3

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
        material: new LOI.Engine.Materials.SpriteMaterial

      animatedMesh.blendTime 0.2
      animatedMesh.currentAnimationName 'Idle'
      animatedMesh.randomStart true

      sideIndex = LOI.HumanAvatar.TextureRenderer.textureSides.indexOf sideName
      bodyHeight = bodyTop[sideIndex] - bodyBottom[sideIndex]
      targetHeight = 1.8 # meters
      scale = targetHeight / bodyHeight

      animatedMesh.scale.multiplyScalar scale
      animatedMesh.position.y = -bodyBottom[sideIndex] * scale
      animatedMesh.scale.x *= -1 if sideAngle < 0
      animatedMesh.visible = false unless side is @currentSide

      @animatedMeshes[side] = animatedMesh

    Tracker.autorun (computation) =>
      # See if we will get texture data, or we need to render them ad-hoc.
      return unless @humanAvatar.dataReady()

      textures = @humanAvatar.options.textures?()

      if not @humanAvatar.customOutfit()
        @_textureUpdateAutorun?.stop()
        
        # Read the textures from the URLs.
        @updatePaletteDataTexture new THREE.TextureLoader().load textures.paletteData.url
        @updateNormalsTexture new THREE.TextureLoader().load textures.normals.url
        @textureUpdateFinished()

        # Make sure the textures are actually reachable and fallback to on-the-fly rendering otherwise.
        image = new Image
        image.addEventListener 'error', =>
          console.warn "Couldn't reach avatar texture", textures.paletteData.url
          
          # Set the current outfit as a custom outfit to trigger rendering.
          @humanAvatar.customOutfit @humanAvatar.outfit.options.dataLocation.options.rootField.options.load()
        ,
          false

        image.src = textures.paletteData.url

      else
        # Create texture renderers.
        @humanAvatarRenderer ?= new LOI.Character.Avatar.Renderers.HumanAvatar
          humanAvatar: @humanAvatar
          renderTexture: true
        ,
          true
    
        # Create and automatically update textures.
        @textureRenderer ?= new LOI.HumanAvatar.TextureRenderer
          humanAvatar: @humanAvatar
          humanAvatarRenderer: @humanAvatarRenderer
    
        @_textureUpdateAutorun = Tracker.autorun (computation) =>
          # Render scaled palette data and normal textures.
          return unless @textureRenderer.render()
    
          @updatePaletteDataTexture new THREE.CanvasTexture @textureRenderer.scaledPaletteDataCanvas
          @updateNormalsTexture new THREE.CanvasTexture @textureRenderer.scaledNormalsCanvas
    
          debugCanvas = $('<canvas>')[0]
          debugScale = 8
          debugCanvas.width = 1024 * debugScale
          debugCanvas.height = 128 * debugScale
          debugContext = debugCanvas.getContext '2d'
          debugContext.imageSmoothingEnabled = false
          debugContext.drawImage @textureRenderer.paletteDataCanvas, 0, 0, debugCanvas.width, debugCanvas.height
          debugContext.fillStyle = 'white'
          debugContext.lineWidth = 1 / debugScale
    
          for side, sideIndex in LOI.HumanAvatar.TextureRenderer.textureSides
            debugContext.setTransform debugScale, 0, 0, debugScale, 100 * sideIndex * debugScale, 0
    
            if @constructor.debugLandmarks
              for landmark in @humanAvatarRenderer.bodyRenderer.landmarks[side]() when landmark.regionId
                debugContext.fillRect landmark.x + 0.25, landmark.y + 0.25, 0.5, 0.5
    
            if @constructor.debugMapping
              for articleRenderer in @humanAvatarRenderer.outfitRenderer.renderers()
                for articlePartRenderer in articleRenderer.renderers()
                  for mappedShapeRenderer in articlePartRenderer.renderers()
                    continue unless delaunay = mappedShapeRenderer.debugDelaunay[side]()
    
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
          @textureUpdateFinished()

  destroy: ->
    super arguments...

    @humanAvatarRenderer?.destroy()
    @_textureUpdateAutorun?.stop()

    animatedMesh.destroy() for side, animatedMesh of @animatedMeshes

  updatePaletteDataTexture: (texture) ->
    texture.magFilter = THREE.NearestFilter
    texture.minFilter = THREE.NearestFilter

    # We update the map (via texture field).
    for side, animatedMesh of @animatedMeshes
      animatedMesh.texture texture
      animatedMesh.options.material.needsUpdate = true

      # HACK: We also manually have to update the values of uniforms, to actually change the texture.
      animatedMesh.options.material.uniforms.map.value = texture

  updateNormalsTexture: (texture) ->
    # We update the normal map field on material so that appropriate shader defines get turned on.
    for side, animatedMesh of @animatedMeshes
      animatedMesh.options.material.normalMap = texture
      animatedMesh.options.material.needsUpdate = true

      # HACK: We also manually have to update the values of uniforms, to actually change the texture.
      animatedMesh.options.material.uniforms.normalMap.value = texture

  textureUpdateFinished: ->
    unless @_textureRendered
      @_textureRendered = true

      # Add all animated meshes to the object.
      for side, sideAngle of LOI.Engine.RenderingSides.angles
        @add @animatedMeshes[side]

  update: (appTime, options = {}) ->
    return unless @_textureRendered

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
    
  setCurrentSide: (side) ->
    previousAnimatedMesh = @animatedMeshes[@currentSide]
    previousAnimatedMesh.visible = false

    @currentSide = side
    @animatedMeshes[@currentSide].visible = true
    @animatedMeshes[@currentSide].syncAnimationTo previousAnimatedMesh

  facePosition: (positionOrLandmark) ->
    facingPosition = LOI.adventure.world.getPositionVector positionOrLandmark
    @faceDirection new THREE.Vector3().subVectors facingPosition, @position

  faceDirection: (direction) ->
    @_targetAngle = LOI.Engine.RenderingSides.getAngleForDirection direction
    @_angleChange = 0
    @_totalAngleChange = _.angleDistance @_targetAngle, @currentAngle
    @_angleChangeSpeed = 4 * Math.sign _.angleDifference @_targetAngle, @currentAngle
