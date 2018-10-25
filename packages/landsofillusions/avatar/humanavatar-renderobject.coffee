AS = Artificial.Spectrum
LOI = LandsOfIllusions

class LOI.HumanAvatar extends LOI.HumanAvatar
  constructor: ->
    super arguments...

    @textureDataUrl = new ReactiveField null

  destroy: ->
    super arguments...

    @_textureUpdateAutorun.stop()
    @_renderObject?.destroy()

  getRenderObject: ->
    return @_renderObject if @_renderObject

    # Create animated mesh for this human.
    Tracker.nonreactive =>
      @_renderObject = new AS.AnimatedMesh
        dataUrl: '/landsofillusions/avatar/front.json'
        castShadow: true
        receiveShadow: true
        material: new LOI.Engine.SpriteMaterial

      @_renderObject.currentAnimationName if Math.random() < 0.5 then 'shiftWeight' else 'idle'

      # Automatically update the texture.
      textureCanvas = $('<canvas>')[0]
      textureCanvas.width = 64
      textureCanvas.height = 64
      textureContext = textureCanvas.getContext '2d'

      normalCanvas = $('<canvas>')[0]
      normalCanvas.width = 64
      normalCanvas.height = 64
      normalContext = normalCanvas.getContext '2d'

      @_normalCanvas = normalCanvas

      @_textureUpdateAutorun = Tracker.autorun (computation) =>
        return unless renderer = @renderer()

        # Render palette data texture.
        renderPasses = [
          canvas: textureCanvas
          context: textureContext
          options: renderPaletteData: true
          hqxAntialiasing: false
        ,
          canvas: normalCanvas
          context: normalContext
          options: renderNormalData: true
          hqxAntialiasing: true
        ]

        for renderPass in renderPasses
          renderPass.context.setTransform 1, 0, 0, 1, 0, 0
          renderPass.context.clearRect 0, 0, renderPass.canvas.width, renderPass.canvas.height

          renderPass.context.setTransform 1, 0, 0, 1, Math.floor(renderPass.canvas.width / 2), Math.floor(renderPass.canvas.height / 2)
          renderPass.context.save()

          renderer.drawToContext renderPass.context, _.extend
            rootPart: renderer.options.part
            useTextureOffsets: true
          ,
            renderPass.options

          renderPass.context.restore()

          renderPass.scaledCanvas = AS.Hqx.scale renderPass.canvas, 4, AS.Hqx.Modes.Default, renderPass.hqxAntialiasing

          renderPass.texture = new THREE.CanvasTexture renderPass.scaledCanvas
          renderPass.texture.magFilter = THREE.NearestFilter
          renderPass.texture.minFilter = THREE.NearestFilter

        # We update the map (via texture field) and normal map fields
        # on material so that appropriate shader defines get turned on.
        @_renderObject.texture renderPasses[0].texture
        @_renderObject.options.material.normalMap = renderPasses[1].texture
        @_renderObject.options.material.needsUpdate = true

        # HACK: We also manually have to update the values of uniforms, to actually change the texture.
        @_renderObject.options.material.uniforms.map.value = renderPasses[0].texture
        @_renderObject.options.material.uniforms.normalMap.value = renderPasses[1].texture

        @textureDataUrl renderPasses[0].scaledCanvas.toDataURL()

    @_renderObject
