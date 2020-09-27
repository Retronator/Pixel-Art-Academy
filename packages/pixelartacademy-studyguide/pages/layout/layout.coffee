AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StudyGuide.Pages.Layout extends LOI.Components.EmbeddedWebpage
  @register 'PixelArtAcademy.StudyGuide.Pages.Layout'

  @image: (parameters) ->
    Meteor.absoluteUrl "retropolis/city/academyofart/link-image.png"

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
