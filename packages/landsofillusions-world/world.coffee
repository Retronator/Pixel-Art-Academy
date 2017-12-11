AM = Artificial.Mirage
AB = Artificial.Base

class LandsOfIllusions.World
  constructor: ->
    AB.Router.addRoute 'landsofillusions.world/', @constructor.Layouts.Center, @constructor.Pages.Home
