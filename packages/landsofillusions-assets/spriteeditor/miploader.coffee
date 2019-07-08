FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.MipLoader extends FM.Loader
  constructor: ->
    super arguments...

    @_subscription = LOI.Assets.Asset.forPath.subscribe LOI.Assets.Sprite.className, @fileId

    @mipmaps = new ComputedField =>
      escapedFileId = @fileId.replace /\//g, '\\/'

      mipmaps = LOI.Assets.Sprite.documents.fetch
        name: ///^#{escapedFileId}\/.*///

      # Sort largest width to smallest.
      _.sortBy mipmaps, (mipmap) => -(mipmap.bounds?.width or 0)

    @activeMipmap = new ReactiveField null

    @spriteData = new ComputedField =>
      # Refetch the sprite to always have latest data.
      LOI.Assets.Sprite.documents.findOne @activeMipmap()?._id

    @_selectClosestMipmapAutorun = Tracker.autorun (computation) =>
      return if @spriteData()

      mipmaps = @mipmaps()
      return unless mipmaps.length

      if activeWidth = @activeMipmap()?.bounds?.width
        # Select the first mipmap largest than the previous one
        for mipmap, index in mipmaps
          if index >= mipmaps.length or mipmaps[index + 1].width < activeWidth
            newMipmap = mipmap
            break

      else
        # We didn't have a previous mipmap so just select the biggest mipmap.
        newMipmap = _.first mipmaps

      @activeMipmap newMipmap

    # Create the alias for universal operators.
    @asset = @spriteData

    @displayName = new ComputedField => @fileId

    @paintNormalsData = @interface.getComponentData(LOI.Assets.SpriteEditor.Tools.Pencil).child 'paintNormals'

    # Create the engine sprite.
    @sprite = new LOI.Assets.Engine.Sprite
      spriteData: @spriteData
      visualizeNormals: @paintNormalsData.value

    # Subscribe to the referenced palette as well.
    @paletteId = new ComputedField =>
      @spriteData()?.palette?._id

    @_paletteSubscription = Tracker.autorun (computation) =>
      return unless paletteId = @paletteId()
      LOI.Assets.Palette.forId.subscribe paletteId

    @palette = new ComputedField =>
      if paletteId = @paletteId()
        LOI.Assets.Palette.documents.findOne paletteId

      else
        # See if we have an embedded custom palette.
        @spriteData()?.customPalette

  destroy: ->
    @_subscription.stop()
    @spriteData.stop()
    @paletteId.stop()
    @_paletteSubscription.stop()
    @palette.stop()
    @_selectClosestMipmapAutorun.stop()

  activateMipmap: (mipmap) ->
    # Get current scale level.
    pixelCanvas = @interface.getEditorForActiveFile()
    camera = pixelCanvas.camera()
    oldScale = camera.scale()

    # Calculate new scale level so the sprite will appear the same size after the switch.
    activeMipmap = @activeMipmap()
    oldWidth = activeMipmap?.bounds?.width
    newWidth = mipmap.bounds?.width

    if oldWidth and newWidth
      newScale = oldScale / newWidth * oldWidth

      # Calculate new origin so that the sprite will appear in the same place.
      oldCameraOrigin = camera.origin()
      oldSpriteOrigin = activeMipmap.bounds
      newSpriteOrigin = mipmap.bounds
      newCameraOrigin =
        x: newSpriteOrigin.x - (oldSpriteOrigin.x - oldCameraOrigin.x) * oldScale / newScale
        y: newSpriteOrigin.y - (oldSpriteOrigin.y - oldCameraOrigin.y) * oldScale / newScale

      # Apply changes to the camera.
      camera.setScale newScale
      camera.setOrigin newCameraOrigin

    @activeMipmap mipmap
