AS = Artificial.Spectrum
LOI = LandsOfIllusions

class LOI.HumanAvatar.RenderObject extends AS.RenderObject
  @debugLandmarks = false
  @debugMapping = false

  constructor: (@humanAvatar) ->
    super arguments...

    @parentItem = @humanAvatar
    @avatar = @humanAvatar

    @debugTextureDataUrl = new ReactiveField null

    @animatedMeshes = {}

    # Main meshes are the meshes that aren't mirrored.
    @mainAnimatedMeshes = {}

    @currentAngle = 0
    @currentSide = LOI.Engine.RenderingSides.Keys.Front

    bodyBottom = -10.2
    bodyTop = 8.6
    bodyHeight = bodyTop - bodyBottom

    @_rotationEuler = new THREE.Euler
    @_cameraPosition = new THREE.Vector3
    @_cameraRotation = new THREE.Quaternion
    @_cameraScale = new THREE.Vector3
    @_cameraEuler = new THREE.Euler
    @_cameraDirection = new THREE.Vector3
    @_currentDirection = new THREE.Vector3
    @_viewCurrentDirection = new THREE.Vector3
    @_viewPosition = new THREE.Vector3
    @_viewReferencePosition = new THREE.Vector3
    @_frustumPosition = new THREE.Vector3
    @_frustumReferencePosition = new THREE.Vector3

    mainRenderingSides = ['front', 'frontLeft', 'left', 'backLeft', 'back']
    mirroredRenderingSides = ['frontRight', 'right', 'backRight']

    for side in mainRenderingSides
      # Create the animated mesh.
      animatedMesh = new AS.AnimatedMesh
        dataUrl: "/landsofillusions/avatar/#{_.toLower side}.json"
        dataFPS: 60
        playbackFPS: 20
        castShadow: true
        receiveShadow: true
        material: new LOI.Engine.Materials.SpriteMaterial
        waitForBoneCorrections: true

      animatedMesh.blendTime 0.2
      animatedMesh.currentAnimationName 'Idle loop'
      animatedMesh.randomStart true

      animatedMesh.visible = false unless side is @currentSide

      @animatedMeshes[side] = animatedMesh
      @mainAnimatedMeshes[side] = animatedMesh

      do (animatedMesh) =>
        animatedMesh._updateCreatureRendererAutorun = Tracker.autorun (computation) =>
          return unless creatureRenderer = animatedMesh.creatureRenderer()
          console.log "Updating human avatar render object material", @ if LOI.debug

          creatureRenderer.renderMesh.mainMaterial = animatedMesh.options.material
          @scene()?.manager.addedSceneObjects()

    for side in mirroredRenderingSides
      mirrorSide = LOI.Engine.RenderingSides.mirrorSides[side]
      @animatedMeshes[side] = @animatedMeshes[mirrorSide]

    @ready = new ComputedField =>
      for side, animatedMesh of @mainAnimatedMeshes
        # Wait till the animated mesh has an initialized creature renderer.
        return unless animatedMesh.creatureRenderer()

      true

    @_prepareMeshAutorun = Tracker.autorun (computation) =>
      # Bone corrections will need avatar sprites so wait until they are loaded.
      return unless LOI.Assets.Sprite.cacheReady()

      console.log "Preparing human avatar render object mesh", @ if LOI.debug

      heightValue = @humanAvatar.body.properties.height.options.dataLocation()
      heightOptions = LOI.Character.Part.Types.Avatar.Body.options.properties.height.options
      targetHeight = _.clamp heightValue or heightOptions.default, heightOptions.min, heightOptions.max

      for side in mainRenderingSides
        scale = targetHeight / bodyHeight

        animatedMesh = @animatedMeshes[side]
        animatedMesh.scale.set scale, scale, scale
        animatedMesh.position.y = -bodyBottom * scale

        # Calculate bone corrections relative to default body.
        boneCorrections = @_calculateBoneCorrections side

        # We need to transform corrections from pixels to character units. The standard character size is 49 pixels.
        unitsPerPixel = bodyHeight / 49

        for bone, correction of boneCorrections
          correction.x *= unitsPerPixel
          correction.y *= unitsPerPixel

        animatedMesh.boneCorrections boneCorrections

        # Further reposition the character upwards if the body was extended downwards from the navel.
        for bone in ['Acetabulum', 'Upper Leg', 'Lower Leg', 'Foot']
          if correction = boneCorrections["Left #{bone}"]?.y
            animatedMesh.position.y += correction * scale

    @_prepareTexturesAutorun = Tracker.autorun (computation) =>
      # See if we will get texture data, or we need to render them ad-hoc.
      return unless @humanAvatar.dataReady()
      console.log "Preparing human avatar render object textures", @ if LOI.debug

      textures = @humanAvatar.options.textures?()

      # If we have textures prepared and don't have a custom outfit, we load pre-rendered textures.
      if textures?.paletteData and textures?.normals and not @humanAvatar.customOutfit() and not @constructor.debugLandmarks and not @constructor.debugMapping
        console.log "Loading from URL", textures.paletteData.url if LOI.debug

        @_textureUpdateAutorun?.stop()
        
        # Read the textures from the URLs.
        textureLoader = new THREE.TextureLoader()
        textureLoader.crossOrigin = 'use-credentials'

        @updatePaletteDataTexture textureLoader.load textures.paletteData.url
        @updateNormalsTexture textureLoader.load textures.normals.url
        @textureUpdateFinished()

        # Make sure the textures are actually reachable and fallback to on-the-fly rendering otherwise.
        image = new Image
        image.crossOrigin = 'use-credentials'
        image.addEventListener 'error', =>
          console.warn "Couldn't reach avatar texture", textures.paletteData.url
          
          # Set the current outfit as a custom outfit to trigger rendering.
          @humanAvatar.customOutfit @humanAvatar.outfit.options.dataLocation.options.rootField.options.load()
        ,
          false

        image.src = textures.paletteData.url

      else
        console.log "Rendering ad-hoc", @humanAvatarRenderer?, @textureRenderer? if LOI.debug
        # We need to render textures ad-hoc. Create texture renderer.
        @humanAvatarRenderer ?= new LOI.Character.Avatar.Renderers.HumanAvatar
          humanAvatar: @humanAvatar
          renderTexture: true
        ,
          true
    
        @textureRenderer ?= new LOI.HumanAvatar.TextureRenderer
          humanAvatar: @humanAvatar
          humanAvatarRenderer: @humanAvatarRenderer

        # Start reactively updating textures.
        @_textureUpdateAutorun?.stop()
        @_textureUpdateAutorun = Tracker.delayedAutorun (computation) =>
          console.log "Rendering human avatar render object textures", @ if LOI.debug

          # Render scaled palette data and normal textures.
          return unless @textureRenderer.render()
    
          @updatePaletteDataTexture new THREE.CanvasTexture @textureRenderer.scaledPaletteDataCanvas
          @updateNormalsTexture new THREE.CanvasTexture @textureRenderer.scaledNormalsCanvas
    
          debugCanvas = $('<canvas>')[0]
          debugScale = 8
          debugCanvas.width = 1024 * debugScale
          debugCanvas.height = 128 * debugScale
          debugContext = debugCanvas.getContext '2d'
          debugContext.fillStyle = '#ccc'
          debugContext.fillRect 0, 0, debugCanvas.width, debugCanvas.height
          debugContext.imageSmoothingEnabled = false
          debugContext.drawImage @textureRenderer.scaledPaletteDataCanvas, 0, 0, debugCanvas.width, debugCanvas.height
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

    @_prepareMeshAutorun?.stop()
    @_prepareTexturesAutorun?.stop()
    @_textureUpdateAutorun?.stop()

    @humanAvatarRenderer?.destroy()

    for side, animatedMesh of @mainAnimatedMeshes
      animatedMesh._updateCreatureRendererAutorun.stop()
      animatedMesh.destroy()

  updatePaletteDataTexture: (texture) ->
    texture.magFilter = THREE.NearestFilter
    texture.minFilter = THREE.NearestFilter

    # We update the map (via texture field).
    for side, animatedMesh of @mainAnimatedMeshes
      animatedMesh.texture texture
      animatedMesh.options.material.needsUpdate = true

      # HACK: We also manually have to update the values of uniforms, to actually change the texture.
      animatedMesh.options.material.uniforms.map.value = texture

  updateNormalsTexture: (texture) ->
    # We update the normal map field on material so that appropriate shader defines get turned on.
    for side, animatedMesh of @mainAnimatedMeshes
      animatedMesh.options.material.normalMap = texture
      animatedMesh.options.material.needsUpdate = true

      # HACK: We also manually have to update the values of uniforms, to actually change the texture.
      animatedMesh.options.material.uniforms.normalMap.value = texture

  textureUpdateFinished: ->
    unless @_textureRendered
      @_textureRendered = true

      # Add all animated meshes to the object.
      @add animatedMesh for side, animatedMesh of @mainAnimatedMeshes

  update: (appTime, options = {}) ->
    return unless @_textureRendered

    if @_targetAngle?
      # Rotate the character towards target angle.
      angleDelta = @_angleChangeSpeed * appTime.elapsedAppTime
      @_angleChange += Math.abs angleDelta
      @currentAngle += angleDelta

      if @_angleChange > @_totalAngleChange
        @currentAngle = @_targetAngle
        @_targetAngle = null

    # Choose the correct avatar sprite side for the current character rotation and camera.
    camera = options.camera or LOI.adventure.world.cameraManager().camera()
    LOI.Engine.RenderingSides.getDirectionForAngle @currentAngle, @_currentDirection

    # We need to do the determination of rotation in view space since sprite sides are relative to the camera direction.
    @_viewPosition.copy(@position).applyMatrix4 camera.matrixWorldInverse
    @_viewReferencePosition.copy(@position).add(@_currentDirection).applyMatrix4 camera.matrixWorldInverse
    @_viewCurrentDirection.subVectors @_viewReferencePosition, @_viewPosition

    # Scale the direction's X component to correct for perspective distortion
    # (direction towards the camera should result in the Z axis direction).
    @_frustumPosition.set(1, 0, @_viewPosition.z).applyMatrix4 camera.projectionMatrix
    @_frustumReferencePosition.set(1, 0, @_viewReferencePosition.z).applyMatrix4 camera.projectionMatrix

    xScalingFactor = @_frustumReferencePosition.x / @_frustumPosition.x
    @_viewCurrentDirection.x *= xScalingFactor

    # Get the side based on where in the view the character is facing.
    side = LOI.Engine.RenderingSides.getSideForDirection @_viewCurrentDirection
    @setCurrentSide side unless side is @currentSide

    @animatedMeshes[@currentSide].update appTime

    # Avatar sprite should always face the camera.
    camera.matrix.decompose @_cameraPosition, @_cameraRotation, @_cameraScale
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

    # Apply correct flip.
    sign = if @mainAnimatedMeshes[@currentSide] then 1 else -1
    @animatedMeshes[@currentSide].scale.x = sign * Math.abs @animatedMeshes[@currentSide].scale.x

  facePosition: (positionOrLandmark) ->
    facingPosition = LOI.adventure.world.getPositionVector positionOrLandmark
    @faceDirection new THREE.Vector3().subVectors facingPosition, @position

  faceDirection: (direction) ->
    @_targetAngle = LOI.Engine.RenderingSides.getAngleForDirection direction
    @_angleChange = 0
    @_totalAngleChange = _.angleDistance @_targetAngle, @currentAngle
    @_angleChangeSpeed = 4 * Math.sign _.angleDifference @_targetAngle, @currentAngle
