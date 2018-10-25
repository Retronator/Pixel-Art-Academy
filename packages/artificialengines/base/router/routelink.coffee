AM = Artificial.Mirage
AB = Artificial.Base

# Component that displays a span or a link, depending if we're on this route or not. Useful for navigation menus.
class AB.RouteLink extends AM.Component
  @register 'Artificial.Base.RouteLink'

  constructor: (@text, @route, @parameters) ->
    super arguments...

  isRouteActive: ->
    return unless currentRouteData = AB.Router.currentRouteData()
    return unless @route is currentRouteData.route.name

    # Parameters can be passed directly as an object, or constructed with Spacebars as kwargs.
    parameters = @parameters.hash or @parameters

    # All parameters need to match, both ways.
    for parameter, value of parameters
      return unless currentRouteData.parameters[parameter] is value

    for parameter, value of currentRouteData.parameters
      return unless @parameters[parameter] is value

    true
