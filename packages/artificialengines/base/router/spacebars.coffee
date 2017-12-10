AB = Artificial.Base
# Spacebars helpers for Router.

# Create the {{routerPath}} helper.
Template.registerHelper 'routerPath', (path, routeParameters = {}) ->
  # Handle Spacebars' keyword arguments.
  routeParameters = routeParameters.hash if routeParameters instanceof Spacebars.kw

  AB.Router.createPath path, routeParameters

Template.registerHelper 'routerRouteName', ->
  AB.Router.currentRouteName()

Template.registerHelper 'routerParameter', (parameter) ->
  AB.Router.getParameter parameter
