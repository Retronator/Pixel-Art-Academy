AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  _initializeContext: ->
    @currentContext = new ReactiveField null

  enterContext: (contextClassOrId) ->
    contextClass = LOI.Adventure.Context.getClassForId _.thingId contextClassOrId

    contextClass = contextClassOrId if _.isFunction contextClassOrId
    contextClass = LOI.Adventure.Context.getClassForId contextClassOrId if _.isString contextClassOrId

    unless contextClass
      console.error "Requested context", contextClassOrId, "does not exist."
      return

    Tracker.nonreactive =>
      # Instantiate a new context and set it as current.
      @currentContext new contextClass

  exitContext: ->
    @currentContext null
