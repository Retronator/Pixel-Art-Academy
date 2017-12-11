AB = Artificial.Base

class AB.Router
  @routes = {}

  @addRoute: (route) ->
    # Allow sending direct parameters instead of a route instance.
    route = new @Route arguments... unless route instanceof @Route

    @routes[route.name] = route
    
  @findRoute: (host, path) ->
    # Find the route that matches our location.
    for name, route of @routes
      matchData = route.match host, path
      return {route, matchData} if matchData

    null
