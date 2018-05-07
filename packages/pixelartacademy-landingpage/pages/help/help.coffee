AM = Artificial.Mirage

class PixelArtAcademy.LandingPage.Pages.Help extends AM.Component
  @register 'PixelArtAcademy.LandingPage.Pages.Help'

  @version: -> '0.0.1'

  @title: ->
    "Pixel Art Academy // Text adventure help"

  @description: ->
    "A very preliminary guide to text adventuring in Pixel Art Academy."

  @image: ->
    Meteor.absoluteUrl "pixelartacademy/title.png"
