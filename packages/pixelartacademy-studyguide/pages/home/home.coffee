AM = Artificial.Mirage
AB = Artificial.Base
PAA = PixelArtAcademy

class PAA.StudyGuide.Pages.Home extends AM.Component
  @register 'PixelArtAcademy.StudyGuide.Pages.Home'

  @Pages:
    Activities: 'activities'
    StudyPlan: 'study-plan'
    About: 'about'

  @title: (options) ->
    title = "Retropolis Academy of Art Study Guide"

    # On the server we don't have access to route parameters.
    return title if Meteor.isServer

    switch AB.Router.currentParameters().pageOrBook
      when @Pages.StudyPlan then title = "Study Plan // #{title}"
      when @Pages.About then title = "About // #{title}"

    title

  onCreated: ->
    super arguments...

    @activities = new PAA.StudyGuide.Pages.Home.Activities @
    @studyPlan = new PAA.StudyGuide.Pages.Home.StudyPlan @
    @about = new PAA.StudyGuide.Pages.Home.About @

    parentWithDisplay = @ancestorComponentWith 'display'
    @display = parentWithDisplay.display

    @heightConstants =
      title: 28
      navigation: 16
      header: 28 + 16 + 5
      blueprintBottom: 30

    @viewportHeight = new ComputedField =>
      viewport = @display.viewport()
      viewport.viewportBounds.height() / @display.scale()
      
    @contentSafeHeight = new ComputedField =>
      viewport = @display.viewport()
      viewport.safeArea.height()  / @display.scale() - @heightConstants.header
      
    @safeHeightGap = new ComputedField =>
      (@viewportHeight() - @heightConstants.header - @contentSafeHeight()) / 2
      
    @height = new ComputedField =>
      @viewportHeight() - @heightConstants.navigation + @heightConstants.blueprintBottom + @safeHeightGap()

    @widthConstants =
      innerGap: 20

    @viewportWidth = new ComputedField =>
      viewport = @display.viewport()
      viewport.viewportBounds.width() / @display.scale()

    @safeWidth = new ComputedField =>
      viewport = @display.viewport()
      viewport.safeArea.width() / @display.scale()

    @safeWidthGap = new ComputedField =>
      (@viewportWidth() - @safeWidth()) / 2

    @width = new ComputedField =>
      return unless @_componentsCreated()

      (@safeWidthGap() + @widthConstants.innerGap) * 2 + @activities.width() + @studyPlan.width() + @about.width()

  _componentsCreated: ->
    for component in [@activities, @studyPlan, @about]
      return false unless component.isCreated()

    true

  sceneStyle: ->
    return unless @_componentsCreated()

    switch AB.Router.currentParameters().pageOrBook
      when @constructor.Pages.StudyPlan
        top = -@heightConstants.navigation
        left = @studyPlan.left()

      when @constructor.Pages.About
        top = @height() - @viewportHeight()
        left = @width() - @viewportWidth()

      else
        top = @height() - @viewportHeight()
        left = 0

    height: "#{@height()}rem"
    width: "#{@width()}rem"
    top: "#{-top}rem"
    left: "#{-left}rem"
