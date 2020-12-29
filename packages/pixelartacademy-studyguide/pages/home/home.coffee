AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
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

    @layout = @ancestorComponentOfType PAA.StudyGuide.Pages.Layout

    @menu = new @constructor.Menu @
    @activities = new @constructor.Activities @
    @studyPlan = new @constructor.StudyPlan @
    @about = new @constructor.About @
    @book = new @constructor.Book @
    @submissions = new @constructor.Submissions @

    parentWithDisplay = @ancestorComponentWith 'display'
    @display = parentWithDisplay.display

    # Create design properties.
    @heightConstants =
      title: 28
      navigation: 16
      header: 28 + 16 + 5
      blueprintBottom: 79
      tableSafeArea: 5

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
      innerGap: 40

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

    # Initialize Study Guide activities.
    PAA.StudyGuide.Activity.initializeAll @

    # Subscribe to task entries.
    @autorun (computation) =>
      if characterId = LOI.characterId()
        PAA.Learning.Task.Entry.forCharacter.subscribe @, characterId

      else
        PAA.Learning.Task.Entry.forCurrentUser.subscribe @

  _componentsCreated: ->
    for component in [@activities, @studyPlan, @about]
      return false unless component.isCreated()

    true

  signIn: (callback) ->
    # Wait for the user to get signed in.
    userAutorun = Tracker.autorun (computation) =>
      return unless Retronator.user()
      computation.stop()

      # User has signed in. Close the sign-in dialog and return control.
      @menu.signIn.activatable.deactivate()
      callback?()

    @layout.showActivatableModalDialog
      dialog: @menu.signIn
      dontRender: true
      callback: =>
        # User has manually closed the sign-in dialog. Stop waiting and return control.
        userAutorun.stop()
        callback?()

  openSubmissions: (taskId) ->
    # Save scroll position.
    @_lastScrollTop = $(window).scrollTop()

    # Close the book and open submissions for the task.
    @book.close()
    @submissions.open taskId

    # After the book has closed, scroll to top.
    Meteor.setTimeout =>
      $(window).scrollTop 0
    ,
      500

  closeSubmissions: ->
    # Close submissions and re-open the book.
    @submissions.close()

    Meteor.setTimeout =>
      @book.open()

      # After the book became visible again, restore scroll position.
      Meteor.setTimeout =>
        $(window).scrollTop @_lastScrollTop
    ,
      500

  showBackButton: ->
    return unless @book.isCreated()
    @book.book()

  backButtonHiddenClass: ->
    return unless @book.isCreated()

    'back-button-hidden' if @book.focusedArtworks()

  pageClass: ->
    Pages = PAA.StudyGuide.Pages.Home.Pages
    pageOrBook = AB.Router.currentParameters().pageOrBook

    # If first parameter is not defined, we're on activities.
    return Pages.Activities unless pageOrBook

    # Output the page slug if we're on one of the pages.
    pageClasses = _.values Pages
    return pageOrBook if pageOrBook in pageClasses

    # We are on one of the books.
    'book'

  backButtonCallback: ->
    # We must return the callback function.
    =>
      # If we're focusing on an artwork, we close it.
      if @book.focusedArtworks()
        @book.unfocusArtworks()

        # Don't hide the back button.
        return cancel: true

      # If we're displaying submissions, close them and re-open the book.
      if @submissions.opened()
        @closeSubmissions()

        # Don't hide the back button.
        return cancel: true

      # If we're on an activity, return to table of contents.
      if AB.Router.getParameter 'activity'
        @book.goToTableOfContents()

        # Don't hide the back button.
        return cancel: true

      # Otherwise we close the book.
      @book.close()

      Meteor.setTimeout =>
        AB.Router.setParameter 'pageOrBook', null
      ,
        500

  studyPlanRouteOptions: ->
    pageOrBook: PAA.StudyGuide.Pages.Home.Pages.StudyPlan

  aboutRouteOptions: ->
    pageOrBook: PAA.StudyGuide.Pages.Home.Pages.About

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

    backgroundHeight = 396
    backgroundBottom = @safeHeightGap() - 50
    backgroundTop = @height() - backgroundBottom - backgroundHeight

    height: "#{@height()}rem"
    width: "#{@width()}rem"
    top: "#{-top}rem"
    left: "#{-left}rem"
    backgroundPosition: "0 #{backgroundTop}rem"

  tableStyle: ->
    leftPartWidth = 178
    rightPartWidth = 189
    tableHeight = 50

    bottom: "#{@safeHeightGap() - (tableHeight - @heightConstants.tableSafeArea)}rem"
    left: "#{@safeWidthGap() + leftPartWidth}rem"
    right: "#{@safeWidthGap() + rightPartWidth}rem"
