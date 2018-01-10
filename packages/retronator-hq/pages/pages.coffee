AB = Artificial.Base
HQ = Retronator.HQ

class HQ.Pages
  constructor: ->
    # HQ domain also provides the adventure interface.
    AB.Router.addRoute
      url: 'retronator.com/:parameter2?/:parameter3?/:parameter4?/:parameter5?'
      layoutClass: Retronator.App.Layouts.PublicAccess
      pageClass: HQ.Adventure
      parameterDefaults:
        parameter1: 'daily'
