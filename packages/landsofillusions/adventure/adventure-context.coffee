AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  _initializeContext: ->
    @currentContext = new ReactiveField null
    @advertisedContext = new ReactiveField null

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
    
    # Don't react to any advertised context any more.
    @clearAdvertisedContext()

  exitContext: ->
    @currentContext null
    
  advertiseContext: (context) ->
    # You can only advertise a context if we're not already in a context.
    return if @currentContext()
    
    @advertisedContext context

  clearAdvertisedContext: ->
    @advertisedContext null
