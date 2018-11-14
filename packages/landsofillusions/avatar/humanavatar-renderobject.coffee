AS = Artificial.Spectrum
LOI = LandsOfIllusions

class LOI.HumanAvatar extends LOI.HumanAvatar
  constructor: ->
    super arguments...

    @textureDataUrl = new ReactiveField null

  destroy: ->
    super arguments...

    @_textureUpdateAutorun.stop()
    @_animatedMesh?.destroy()

  getRenderObject: ->
    return @_renderObject if @_renderObject

    # Create animated mesh for this human.
    Tracker.nonreactive =>
      @_animatedMesh = new AS.AnimatedMesh
        dataUrl: '/landsofillusions/avatar/front.json'
        castShadow: true
        receiveShadow: true
        material: new LOI.Engine.SpriteMaterial

      @_animatedMesh.currentAnimationName 'Idle'

      bodyBottom = -10.4
      bodyTop = 6

      bodyHeight = bodyTop - bodyBottom
      targetHeight = 1.8 # meters
      scale = targetHeight / bodyHeight

      @_animatedMesh.scale.multiplyScalar scale
      @_animatedMesh.position.y = -bodyBottom * scale

      @_renderObject = new AS.RenderObject
      @_renderObject.update = (appTime) => @_animatedMesh.update appTime
      @_renderObject.add @_animatedMesh

      console.log "RO", @_renderObject

      # Automatically update the texture.
      textureCanvas = $('<canvas>')[0]
      textureCanvas.width = 1024
      textureCanvas.height = 128
      textureContext = textureCanvas.getContext '2d'

      normalCanvas = $('<canvas>')[0]
      normalCanvas.width = 1024
      normalCanvas.height = 128
      normalContext = normalCanvas.getContext '2d'

      @_normalCanvas = normalCanvas

      @_textureUpdateAutorun = Tracker.autorun (computation) =>
        # Render palette color map.
        textureContext.setTransform 1, 0, 0, 1, 0, 0
        textureContext.clearRect 0, 0, textureCanvas.width, textureCanvas.height

        textureContext.save()

        for sideIndex in [0..7]
          continue unless renderer = @textureRenderers[sideIndex]()

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

        for sideIndex in [0..7]
          continue unless renderer = @textureRenderers[sideIndex]()

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
        @_animatedMesh.texture texture
        @_animatedMesh.options.material.normalMap = normalMap
        @_animatedMesh.options.material.needsUpdate = true

        # HACK: We also manually have to update the values of uniforms, to actually change the texture.
        @_animatedMesh.options.material.uniforms.map.value = texture
        @_animatedMesh.options.material.uniforms.normalMap.value = normalMap

        @textureDataUrl textureScaledCanvas.toDataURL()

    @_renderObject
