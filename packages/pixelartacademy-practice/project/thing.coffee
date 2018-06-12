AE = Artificial.Everywhere
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Project.Thing extends LOI.Adventure.Thing
  constructor: (@projectId) ->
    super

  assetsData: ->
    PAA.Practice.Project.documents.findOne(@projectId)?.assets

  assets: -> throw AE.NotImplementedException "Project must provide an array of asset instances currently active in the project."
