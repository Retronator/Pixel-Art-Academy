AM = Artificial.Mirage
AB = Artificial.Base
PAA = PixelArtAcademy

class PAA.StudyGuide.Pages.Home.Activities extends AM.Component
  @register 'PixelArtAcademy.StudyGuide.Pages.Home.Activities'

  constructor: (@home) ->
    super arguments...

  onCreated: ->
    super arguments...

    @left = new ComputedField => @home.safeWidthGap()

    @width = new ComputedField =>
      200

  activitiesStyle: ->
    left: "#{@left()}rem"
    bottom: "#{@home.safeHeightGap()}rem"
    width: "#{@width()}rem"
    height: "#{@home.contentSafeHeight()}rem"
