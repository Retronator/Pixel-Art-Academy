AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
AOA = Retropolis.City.Pages.AcademyOfArt

class AOA.Layout extends LOI.Components.EmbeddedWebpage
  @register 'Retropolis.City.Pages.AcademyOfArt.Layout'

  @title: (options) ->
    "Retropolis Academy of Art"

  @image: (parameters) ->
    Meteor.absoluteUrl "retropolis/city/academyofart/link-image.png"

  rootClass: -> 'retropolis-academyofart'
