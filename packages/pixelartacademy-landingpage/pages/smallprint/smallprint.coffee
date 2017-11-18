AM = Artificial.Mirage

class PixelArtAcademy.LandingPage.Pages.Smallprint extends AM.Component
  @register 'PixelArtAcademy.LandingPage.Pages.Smallprint'

  @version: -> '0.0.1'

  @title: ->
    "Retronator // Smallprint"

  @description: ->
    "Terms of service and privacy policy."

  @image: ->
    Meteor.absoluteUrl "pixelartacademy/title.png"
