AE = Artificial.Everywhere
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.Portfolio.AssetsProviderData
  @_assetsProviderDataById = {}
  
  @getForAssetsProvider: (assetsProvider, thing, index) ->
    assetsProviderData = @_assetsProviderDataById[assetsProvider.id()] ?= Tracker.nonreactive => new @ assetsProvider, thing
    
    # Double check that instances are stable until destroy is called.
    unless assetsProviderData.assetsProvider is assetsProvider
      console.warn "Requested asset provider for a different assets provider instance with the same ID.", assetsProvider.id(), assetsProviderData.assetsProvider, assetsProvider
    
    assetsProviderData.index = index
    assetsProviderData
  
  @destroy: ->
    for assetProviderId, assetProvider of @_assetsProviderDataById
      assetProvider.destroy()
    
    @_assetsProviderDataById = {}
    
  constructor: (@assetsProvider, @thing) ->
    @assets = Tracker.nonreactive => new AE.LiveComputedField =>
      return unless assetInstances = @assetsProvider.assets()
      
      for asset, assetIndex in assetInstances when asset.urlParameter()
        PAA.PixelPad.Apps.Drawing.Portfolio.AssetData.getForAsset asset, assetIndex
    ,
      _.arraysHaveSameValues

  destroy: ->
    @assets.stop()
