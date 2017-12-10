AB = Artificial.Base

pathToRegExp = require 'path-to-regexp'

class AB.Router.Route
  constructor: (@url, @layoutClass, @componentClass) ->
    @name = @componentClass.componentName()

    # Split the url into host and path parts
    [_, @host, @path] = @url.match /(.*?)(\/.*)/

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
