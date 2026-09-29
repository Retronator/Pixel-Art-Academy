AE = Artificial.Everywhere
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Project.AssetsProvider extends PAA.Practice.AssetsProvider
  constructor: (@project, @projectId) ->
    super arguments...

  id: -> @projectId
  
  projectData: -> PAA.Practice.Project.documents.findOne @projectId

  name: -> @projectData()?.name

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

  assetsData: -> @projectData()?.assets
