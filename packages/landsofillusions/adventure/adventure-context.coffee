AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  _initializeContext: ->
    @currentContext = new ReactiveField null

  enterContext: (contextClassOrId) ->
    # Allow sending instantiated context.
    if contextClassOrId instanceof LOI.Adventure.Context
      context = contextClassOrId

    else
      contextClass = LOI.Adventure.Context.getClassForId _.thingId contextClassOrId

      contextClass = contextClassOrId if _.isFunction contextClassOrId
      contextClass = LOI.Adventure.Context.getClassForId contextClassOrId if _.isString contextClassOrId

      unless contextClass
        console.error "Requested context", contextClassOrId, "does not exist."
        return

      # Instantiate the new context.
      Tracker.nonreactive =>
        context = new contextClass

    # Set context as current to activate it.
    @currentContext context

  exitContext: ->
    @currentContext null
