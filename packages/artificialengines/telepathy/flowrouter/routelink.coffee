AM = Artificial.Mirage
AT = Artificial.Telepathy

# Component that displays a span or a link, depending if we're on this route or not. Useful for navigation menus.
class AT.RouteLink extends AM.Component
  @register 'RouteLink'

  constructor: (@text, @route) ->
