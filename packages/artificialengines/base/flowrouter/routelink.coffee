AM = Artificial.Mirage
AB = Artificial.Base

# Component that displays a span or a link, depending if we're on this route or not. Useful for navigation menus.
class AB.RouteLink extends AM.Component
  @register 'Artificial.Base.RouteLink'

  constructor: (@text, @route, @parameters) ->

  isRouteActive: ->
    routeName = FlowRouter.getRouteName()
    return unless @route is routeName

    # All parameters need to match, both ways.
    for parameter, value of @parameters
      return unless FlowRouter.getParam(parameter) is value

    for parameter, value of FlowRouter.current().params
      return unless @parameters[parameter] is value

    true
