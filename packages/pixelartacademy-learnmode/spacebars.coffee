LOI = LandsOfIllusions
AB = Artificial.Base
LM = PixelArtAcademy.LearnMode

Template.registerHelper 'isLearnMode', ->
  # See if the router handler is Learn Mode adventure.
  AB.Router.currentRouteName() is LM.Adventure.id()
