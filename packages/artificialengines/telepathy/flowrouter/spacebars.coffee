# Spacebars helpers for Flow Router.

# Create the {{flowRouterPath}} helper.
Template.registerHelper 'flowRouterPath', (pathDef, routeParameters = {}) ->
  # Handle Spacebars' keyword arguments.
  routeParameters = routeParameters.hash if routeParameters instanceof Spacebars.kw

  FlowRouter.path pathDef, routeParameters

Template.registerHelper 'flowRouterRouteName', ->
  FlowRouter.getRouteName()
