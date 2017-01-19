AT = Artificial.Telepathy

# Add route to Flow Router using Blaze Layout.
AT.addRoute = (name, url, layout, page) ->
  FlowRouter.route url,
    name: name
    action: (params, queryParams) ->
      BlazeLayout.render layout,
        page: page
