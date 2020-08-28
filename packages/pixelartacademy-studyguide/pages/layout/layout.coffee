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
    switch AB.Router.currentParameters().pageOrBook
      when PAA.StudyGuide.Pages.Home.Pages.StudyPlan
        top: "-28rem"
        height: "44rem"

      else
        top: 0
        height: "49rem"

  studyPlanRouteOptions: ->
    pageOrBook: PAA.StudyGuide.Pages.Home.Pages.StudyPlan

  aboutRouteOptions: ->
    pageOrBook: PAA.StudyGuide.Pages.Home.Pages.About
