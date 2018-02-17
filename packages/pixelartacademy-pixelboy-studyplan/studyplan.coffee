AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.StudyPlan extends PAA.PixelBoy.App
  # goals: array of goals placed in the study plan
  #   type: id of the goal
  #   position: where the goal should appear on the canvas
  #     x
  #     y
  #   expanded: boolean if goal's tasks are displayed
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.StudyPlan'
  @url: -> 'studyplan'

  @version: -> '0.0.1'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Study Plan"
  @description: ->
    "
      An app to design your learning curriculum.
    "

  @initialize()

  constructor: ->
    super

    @setDefaultPixelBoySize()
