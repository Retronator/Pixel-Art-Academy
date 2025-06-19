AE = Artificial.Everywhere
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Project.Thing extends LOI.Adventure.Thing
  constructor: (@projectId) ->
    super arguments...

  assetsData: ->
    PAA.Practice.Project.documents.findOne(@projectId)?.assets

  assets: -> throw AE.NotImplementedException "Project must provide an array of asset instances currently active in the project."

  getAsset: (assetClassOrId) ->
    assetId = _.thingId assetClassOrId
    assets = @assets()
    
    _.find assets, (asset) => asset.id() is assetId
