LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.Portfolio.AssetData
  @_assetDataById = {}

  @getForAsset: (asset, index) ->
    assetData = @_assetDataById[asset.id()] ?= Tracker.nonreactive => new @ asset

    # Double check that instances are stable until destroy is called.
    unless assetData.asset is asset
      console.warn "Requested asset data for a different asset instance with the same ID.", asset.id(), assetData.asset, asset

    assetData.index = index
    assetData

  @destroy: ->
    for assetDataId, assetData of @_assetDataById
      assetData.destroy()

    @_assetDataById = {}

  constructor: (@asset) ->
    @_idAutorun = Tracker.autorun (computation) =>
      @_id = @asset.urlParameter()

  destroy: ->
    @_idAutorun.stop()

  scale: =>
    maxSize = 70
    size = Math.max @asset.width(), @asset.height()
    displayScale = LOI.adventure.interface.display.scale()

    unless @asset.pixelArtScaling()
      # Without pixel art scaling, make the image fit into the 70px.
      maxWindowPixelSize = 70 * displayScale
      displaySize = Math.min size, maxWindowPixelSize
      return displaySize / size / displayScale

    # with pixel art scaling, scale the image as much as possible (up to 6) while remaining under 70px.
    return 1 if _.isNaN size

    scale = 1

    if size > maxSize
      # The asset is bigger than our maximum size, so we will need to scale downwards. We start
      # operating in effective scale to still have integer magnification compared to window pixels.
      maxEffectiveSize = maxSize * displayScale

      effectiveScale = displayScale
      effectiveScale-- while size * effectiveScale > maxEffectiveSize

      return effectiveScale / displayScale if effectiveScale > 0

      # We need to reduce scale below 1 effective pixel so we start dividing by integer amounts below 1.
      divisor = 1
      divisor++ while size / divisor > maxEffectiveSize

      effectiveScale = 1 / divisor
      return effectiveScale / displayScale

    scale++ while scale < 6 and (scale + 1) * size < maxSize

    scale
