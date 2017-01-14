# Add route to Flow Router using Blaze Layout.
Artificial.Telepathy.addRoute = (name, url, layout, page) ->
  FlowRouter.route url,
    name: name
    action: (params, queryParams) ->
      BlazeLayout.render layout,
        page: page
