AB = Artificial.Base
LOI = LandsOfIllusions
HQ = Retronator.HQ

class HQ.Adventure extends LOI.Adventure
  @id: -> 'Retronator.HQ.Adventure'
  @register @id()

  template: -> 'LandsOfIllusions.Adventure'

  currentUrl: ->
    # HACK: Feed the 'daily' parameter into the URL so that adventure routing will trigger the daily direct route.
    prefix = 'retronator'

    parameters = AB.Router.currentParameters()
    prefix = 'daily' if parameters.parameter2 in [undefined, 'page', 'tagged', 'post']

    "/#{prefix}#{AB.Router.currentRoutePath()}"
