AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StudyGuide.Pages.Layout extends LOI.Components.EmbeddedWebpage
  @image: (parameters) ->
    Meteor.absoluteUrl "retropolis/city/academyofart/link-image.png"

  onCreated: ->
    super arguments...

    PAA.Learning.Task.Entry.forCurrentUser.subscribe @

  signIn: (callback) ->
    signInDialog = new LOI.Components.SignIn

    # Wait for the user to get signed in.
    userAutorun = Tracker.autorun (computation) =>
      return unless Retronator.user()
      computation.stop()

      # User has signed in. Close the sign-in dialog and return control.
      signInDialog.activatable.deactivate()
      callback?()

    @showActivatableModalDialog
      dialog: signInDialog
      callback: =>
        # User has manually closed the sign-in dialog. Stop waiting and return control.
        userAutorun.stop()
        callback?()

  rootClass: -> 'pixelartacademy-studyguide'

  headerStyle: ->
    Pages = PAA.StudyGuide.Pages.Home.Pages
    pageOrBook = AB.Router.currentParameters().pageOrBook

    switch pageOrBook
      when Pages.StudyPlan
        top: "-28rem"
        height: "44rem"

      when Pages.Activities, Pages.About, undefined
        top: 0
        height: "49rem"

      else
        # We're on a book.
        top: "-49rem"

  studyPlanRouteOptions: ->
    pageOrBook: PAA.StudyGuide.Pages.Home.Pages.StudyPlan

  aboutRouteOptions: ->
    pageOrBook: PAA.StudyGuide.Pages.Home.Pages.About
