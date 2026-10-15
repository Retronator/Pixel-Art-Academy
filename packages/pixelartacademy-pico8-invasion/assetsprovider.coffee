AE = Artificial.Everywhere
PAA = PixelArtAcademy

class PAA.Pico8.Cartridges.Invasion.Project.AssetsProvider extends PAA.Practice.Project.AssetsProvider
  constructor: ->
    super arguments...

    @_assets = {}
    @_designDocumentAsset = Tracker.nonreactive => new PAA.Pico8.Cartridges.Invasion.DesignDocument.Asset @

    @assets = new AE.LiveComputedField =>
      assetsData = @assetsData() or []

      for assetData in assetsData when not @_assets[assetData.id]
        assetClass = PAA.Practice.Asset.getClassForId assetData.id
        @_assets[assetData.id] = Tracker.nonreactive => new assetClass @

      [
        _.values(@_assets)...
        @_designDocumentAsset
      ]
    ,
      _.arraysHaveSameValues

  destroy: ->
    @assets.stop()
    @_designDocumentAsset.destroy()
    asset.destroy() for assetId, asset of @_assets
