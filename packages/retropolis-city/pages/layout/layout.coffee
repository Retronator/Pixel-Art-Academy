AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
Pages = Retropolis.City.Pages

class Pages.Layout extends LOI.Components.EmbeddedWebpage
  @register 'Retropolis.City.Pages.Layout'

  @title: (options) ->
    "Retropolis — City of Dreams"

  rootClass: -> 'retropolis-city'
