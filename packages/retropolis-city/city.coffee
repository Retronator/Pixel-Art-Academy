AM = Artificial.Mirage
AB = Artificial.Base

class Retropolis.City
  constructor: ->
    AB.Router.addRoute 'retropolis.city/', @constructor.Layouts.City, @constructor.Pages.Home
