AM = Artificial.Mirage
AB = Artificial.Base
PAA = PixelArtAcademy

class PAA.StudyGuide.Pages.Home.StudyPlan extends AM.Component
  @register 'PixelArtAcademy.StudyGuide.Pages.Home.StudyPlan'

  constructor: (@home) ->
    super arguments...

  onCreated: ->
    super arguments...

    @left = new ComputedField => @home.activities.left() + @home.activities.width() + @home.widthConstants.innerGap

    @width = new ComputedField =>
      @home.viewportWidth()

  studyPlanStyle: ->
    left: "#{@left()}rem"
    top: "0rem"
    width: "#{@width()}rem"
    height: "#{@home.viewportHeight() - @home.heightConstants.navigation}rem"
