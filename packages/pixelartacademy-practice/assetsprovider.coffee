AE = Artificial.Everywhere
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.AssetsProvider
  @id: -> throw new AE.NotImplementedException "Assets provider must provide an ID."
  id: -> @constructor.id()

  assets: -> throw new AE.NotImplementedException "Assets provider must provide asset instances."

  assetsData: -> throw new AE.NotImplementedException "Assets provider must provide data to the assets."
  
  getAsset: (assetClassOrId) ->
    assetId = _.thingId assetClassOrId
    assets = @assets()
    
    _.find assets, (asset) => asset.id() is assetId
