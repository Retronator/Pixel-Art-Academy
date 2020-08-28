AM = Artificial.Mirage
AB = Artificial.Base
PAA = PixelArtAcademy

class PAA.StudyGuide.Pages.Home.About extends AM.Component
  @register 'PixelArtAcademy.StudyGuide.Pages.Home.About'

  constructor: (@home) ->
    super arguments...

  onCreated: ->
    super arguments...

    @left = new ComputedField => @home.studyPlan.left() + @home.studyPlan.width() + @home.widthConstants.innerGap

    @width = new ComputedField =>
      120

  aboutStyle: ->
    left: "#{@left()}rem"
    bottom: "#{@home.safeHeightGap()}rem"
    width: "#{@width()}rem"
    height: "#{@home.contentSafeHeight()}rem"
