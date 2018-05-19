AE = Artificial.Everywhere
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Project.Thing extends LOI.Adventure.Thing
  constructor: (@projectId) ->
    super
    
    # Find the project data.
    @data = new ComputedField =>
      PAA.Practice.Project.documents.findOne @projectId

  destroy: ->
    super

    @data.stop()

  assets: -> throw AE.NotImplementedException "Project must provide an array of asset instances currently active in the project."
