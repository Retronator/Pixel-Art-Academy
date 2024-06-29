AM = Artificial.Mirage

class PixelArtAcademy.LandingPage.Pages.Press extends AM.Component
  @register 'PixelArtAcademy.LandingPage.Pages.Press'

  @version: -> '0.0.2'

  @title: ->
    "Pixel Art Academy // Press kit"

  @description: ->
    "Information, videos, and artwork about Pixel Art Academy."

  @image: ->
    Meteor.absoluteUrl "pixelartacademy/title.png"
