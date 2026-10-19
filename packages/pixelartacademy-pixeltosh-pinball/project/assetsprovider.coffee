AE = Artificial.Everywhere
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Project.AssetsProvider extends PAA.Practice.Project.AssetsProvider
  constructor: ->
    super arguments...

    @_assets = {}

    @assets = new AE.LiveComputedField =>
      assetsData = @assetsData() or []
      assets = []

      for assetData in assetsData
        unless @_assets[assetData.id]
          assetClass = PAA.Practice.Asset.getClassForId assetData.id
          @_assets[assetData.id] = Tracker.nonreactive => new assetClass @
          
        assets.push @_assets[assetData.id]
        
      assets
    ,
      _.arraysHaveSameValues

  destroy: ->
    @assets.stop()
    asset.destroy() for assetId, asset of @_assets
