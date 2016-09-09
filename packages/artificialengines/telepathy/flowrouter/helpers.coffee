# Create the {{flowRouterPath}} helper.
Template.registerHelper 'flowRouterPath', (pathDef, kw) ->
  params = if kw?.hash then kw.hash else {}

  FlowRouter.path pathDef, params

Template.registerHelper 'flowRouterRouteName', ->
  FlowRouter.getRouteName()
