AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Planning.Instructions.StudyPlan extends PAA.PixelPad.Systems.Instructions
  @id: -> 'PixelArtAcademy.Tutorials.Planning.Instructions.StudyPlan'

  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Study Plan instructions"
  @description: ->
    "
      System for on-demand display of information in the Study Plan app.
    "

  @initialize()
