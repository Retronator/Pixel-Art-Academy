AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions

class LOI.World.Pages.Layout extends LOI.Components.EmbeddedWebpage
  @register 'LandsOfIllusions.World.Pages.Layout'

  @title: -> LOI.Adventure.title()
  @description: -> LOI.Adventure.description()

  rootClass: -> 'landsofillusions-world'
