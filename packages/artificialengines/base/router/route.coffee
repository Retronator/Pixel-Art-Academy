AB = Artificial.Base

pathToRegExp = require 'path-to-regexp'

class AB.Router.Route
  constructor: (optionsOrUrl, @layoutClass, @pageClass) ->
    if _.isObject optionsOrUrl
      # We were passed an options object so destructure it.
      {@url, @layoutClass, @pageClass, @statusCode} = optionsOrUrl

    else
      # We were passed an url. We expect the rest of the parameters to be set
      @url = optionsOrUrl

    # Default status code is 200. Send in a different value to serve, for example, a 404 page.
    @statusCode ?= 200

    @name = @pageClass.componentName()

    # Split the url into host and path parts
    [match, @host, @path] = @url.match /(.*?)(\/.*)/

    @parameters = []
    @regExp = pathToRegExp @path, @parameters
    @createPath = pathToRegExp.compile @path

  match: (host, path) ->
    # Host matches when the target host ends with the route host.
    return unless _.endsWith host, @host
    
    # If no path is provided, we return true to indicate a host match.
    return true unless path

    # Match the path with the regex.
    return unless match = path.match @regExp

    parametersArray = match[1..]

    # We have a successful match. Build the parameters object.
    parameters = {}

    for parameter, index in @parameters
      parameters[parameter.name] = parametersArray[index]

    # Return the parameters.
    {parameters, parametersArray}
