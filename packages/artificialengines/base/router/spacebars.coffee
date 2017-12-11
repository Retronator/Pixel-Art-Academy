AB = Artificial.Base
# Spacebars helpers for Router.

# Create the {{routerPath}} helper.
Template.registerHelper 'routerPath', (routeName, routeParameters = {}) ->
  # Handle Spacebars' keyword arguments.
  routeParameters = routeParameters.hash if routeParameters instanceof Spacebars.kw

  AB.Router.createUrl routeName, routeParameters

Template.registerHelper 'routerRouteName', ->
  AB.Router.currentRouteName()

Template.registerHelper 'routerParameter', (parameter) ->
  AB.Router.getParameter parameter
