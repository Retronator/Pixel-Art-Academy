AB = Artificial.Base

# Adds a route to client and server side with support for dynamic meta tags.
AB.addRoute = (url, layoutClass, componentClass) ->
  componentName = componentClass.componentName()
  layoutName = layoutClass.componentName()

  AB.routes ?= {}
  AB.routes[componentName] = {layoutClass, componentClass}

  AB.addFlowRouterRoute componentName, url, layoutName, componentName

  if Meteor.isServer
    AB.addPickerRoute url, (routeParameters, request, response, next) =>
      head = {}

      # Call layout first and component later so it can override the more general layout results.
      for target in [layoutClass, componentClass]
        for headParameter in ['title', 'description', 'image']
          # Only override the parameter if we get a result.
          result = target[headParameter]? routeParameters

          # We need to escape the string since we'll be inserting it into html response.
          head[headParameter] = _.escape result if result

      # Set the head.
      headHtml = ""

      if head.title
        headHtml += "<title>#{head.title}</title>\n"
        headHtml += "<meta property='og:title' content='#{head.title}' />\n"

      if head.description
        headHtml += "<meta name='description' content='#{head.description}'>\n"
        headHtml += "<meta property='og:description' content='#{head.description}' />\n"

      if head.image
        headHtml += "<meta property='og:image' content='#{head.image}' />\n"

      # Replace parameters in the url.
      for parameterName, parameter of routeParameters
        url = url.replace ":#{parameterName}", parameter

      # Remove undefined parameters.
      url = url.replace /undefined\?/g, ''

      # Trim leading and ending slashes (that could result when removing parameters).
      url = _.trim url, '/'

      absoluteUrl = Meteor.absoluteUrl url

      headHtml += "<meta property='og:url' content='#{absoluteUrl}' />\n"

      Inject.rawHead 'Artificial.Base.addRoute', headHtml, response

      next()
