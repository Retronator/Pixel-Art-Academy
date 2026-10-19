AE = Artificial.Everywhere
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Project.AssetsProvider extends PAA.Practice.AssetsProvider
  constructor: (@project, @projectId) ->
    super arguments...

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
