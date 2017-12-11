AB = Artificial.Base

class AB.Router
  @routes = {}

  @addRoute: (route) ->
    # Allow sending direct parameters instead of a route instance.
    route = new @Route arguments... unless route instanceof @Route

    @routes[route.name] = route
