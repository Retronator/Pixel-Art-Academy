AB = Artificial.Base

class AB.Router
  @routes = {}
  @error404Routes = {}

  @addRoute: (url, layoutClass, componentClass) ->
    route = new @Route url, layoutClass, componentClass
    @routes[route.name] = route

  @add404: (url, layoutClass, componentClass) ->
    route = new @Route url, layoutClass, componentClass
    @error404Routes[route.name] = route
