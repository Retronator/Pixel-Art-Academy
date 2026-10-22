AE = Artificial.Everywhere
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Project.AssetsProvider extends PAA.Practice.AssetsProvider
  constructor: (@project, @projectId) ->
    super arguments...

    @_assetsById = {}

    @_assets = new AE.LiveComputedField =>
      assetsData = @assetsData() or []
      assets = []

      for assetData in assetsData
        unless @_assetsById[assetData.id]
          assetClass = PAA.Practice.Asset.getClassForId assetData.id
          @_assetsById[assetData.id] = Tracker.nonreactive => new assetClass @
          
        assets.push @_assetsById[assetData.id]
        
      assets
    ,
      _.arraysHaveSameValues

  destroy: ->
    @_assets.stop()
    asset.destroy() for assetId, asset of @_assetsById
    
  id: -> @projectId
  
  projectDocument: -> PAA.Practice.Project.documents.findOne @projectId

  name: -> @projectDocument()?.name

  setName: (name) ->
    name = name?.trim()

    modifier =
      $set:
        lastEditTime: new Date

    if name
      modifier.$set.name = name

    else
      modifier.$unset = name: true

    PAA.Practice.Project.documents.update @projectId, modifier

  assetsData: -> @projectDocument()?.assets
  
  assets: -> @_assets()
