AE = Artificial.Everywhere
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Project.AssetsProvider extends PAA.Practice.AssetsProvider
  constructor: (@project, @projectId) ->
    super arguments...

  id: -> @projectId
  
  assetsData: -> PAA.Practice.Project.documents.findOne(@projectId)?.assets
