AB = Artificial.Base

# Add route to Flow Router using Blaze Layout.
AB.addFlowRouterRoute = (name, url, layout, page) ->
  FlowRouter.route url,
    name: name
    action: (params, queryParams) ->
      BlazeLayout.render layout,
        page: page
