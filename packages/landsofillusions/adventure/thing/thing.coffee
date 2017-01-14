AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action
Talking = LOI.Adventure.Ability.Talking

class LOI.Adventure.Thing extends AM.Component
  template: -> 'LandsOfIllusions.Adventure.Thing'
    
  # Static thing properties and methods

  # A map of all thing constructors by url and ID.
  @_thingClassesByUrl = {}
  @_thingClassesByWildcardUrl = {}
  @_thingClassesById = {}

  # Id string for this thing used to identify the thing in code.
  @id: -> throw new Meteor.Error 'unimplemented', "You must specify thing's id."

  # The URL at which the thing is accessed or null if it doesn't use an address.
  @url: -> null

  # Generates the parameters object that can be passed to the router to get to this thing URL.
  @urlParameters: ->
    # Split URL into object with parameter properties.
    urlParameters = @url().split('/')

    parametersObject = {}

    for urlParameter, i in urlParameters
      parametersObject["parameter#{i + 1}"] = urlParameter unless urlParameter is '*'

    parametersObject

  # The long name is displayed to succinctly describe the thing. Also, we can't just use 'name'
  # instead of 'fullName' because name gets overriden by CoffeeScript with the class name.
  @fullName: -> throw new Meteor.Error 'unimplemented', "You must specify thing's full name."

  # The short name of the thing which is used to refer to it in the text. 
  @shortName: -> @fullName()

  # The description text displayed when you enter the thing for the first time or specifically look around. Default
  # (null) means no description.
  @description: -> null

  # Helper methods to access class constructors.
  @getClassForUrl: (url) ->
    thingClass = @_thingClassesByUrl[url]
    return thingClass if thingClass

    # Try wildcard urls as well.
    for thingUrl, thingClass of @_thingClassesByWildcardUrl
      if url.indexOf(thingUrl) is 0
        return thingClass

  @getClassForId: (id) ->
    @_thingClassesById[id]

  # Start all things with a WIP version.
  @version: -> "0.0.1-#{@wipSuffix}"

  @listenerClasses: -> [] # Override for listeners to be initialized when thing is created.

  @initialize: ->
    # Store thing class by ID and url.
    @_thingClassesById[@id()] = @

    url = @url()
    if url?
      # See if we have a wildcard URL.
      if match = url.match /(.*)\/\*$/
        url = match[1]
        @_thingClassesByWildcardUrl[url] = @

      else
        @_thingClassesByUrl[url] = @

    # Prepare the avatar for this thing.
    LOI.Avatar.initialize @

  @state: -> {} # Override to return a non-empty state.

  # Thing instance

  constructor: (@options) ->
    super

    @avatar = new LOI.Avatar @constructor
    @abilities = new ReactiveField []

    # State object for this thing.
    @address = new LOI.StateAddress "things.#{@id()}"
    @stateObject = new LOI.StateObject
      address: @address

    @_autorunHandles = []
    @_subscriptionHandles = []
    
    @listeners = []
    for listenerClass in @constructor.listenerClasses()
      @listeners.push new listenerClass
        parent: @

  destroy: ->
    @avatar.destroy()
    for ability in @abilities()
      # Break the two-way relationship and let the ability do any additional cleanup.
      ability.thing null
      ability.destroy()

    handle.stop() for handle in _.union @_autorunHandles, @_subscriptionHandles

  # Convenience methods for static properties.
  id: -> @constructor.id()

  ready: ->
    conditions = _.flattenDeep [
      @avatar.ready()
      listener.ready() for listener in @listeners
    ]

    _.every conditions

  # A variant of autorun that works even when the component isn't being rendered.
  autorun: (handler) ->
    # If we're already created, we can simply use default implementation
    # that will stop the autorun when component is removed from DOM.
    return super if @isCreated()

    handle = Tracker.autorun handler
    @_autorunHandles.push handle

    handle

  # A variant of subscribe that works even when the component isn't being rendered.
  subscribe: (subscriptionName) ->
    # If we're already created, we can simply use default implementation
    # that will stop the subscribe when component is removed from DOM.
    return super if @isCreated()

    handle = Meteor.subscribe subscriptionName
    @_subscriptionHandles.push handle

    handle

  addAbility: (ability) ->
    # Create a two-way relationship and add the ability to the list.
    ability.thing @
    @abilities @abilities().concat ability
  
  addAbilityToActivateByLooking: ->
    @addAbility new Action
      verb: Vocabulary.Keys.Verbs.Look
      action: =>
        LOI.adventure.goToItem @constructor.id()

  addAbilityToActivateByLookingOrUsing: ->
    @addAbility new Action
      verbs: [Vocabulary.Keys.Verbs.Look, Vocabulary.Keys.Verbs.Use]
      action: =>
        LOI.adventure.goToItem @constructor.id()
          
  addAbilityToActivateByReading: ->
    @addAbility new Action
      verbs: [Vocabulary.Keys.Verbs.Read, Vocabulary.Keys.Verbs.Look, Vocabulary.Keys.Verbs.Use]
      action: =>
        LOI.adventure.goToItem @constructor.id()
        
  # Helper to access running scripts.
  currentScriptNodes: ->
    LOI.adventure.director.currentScriptNodes() or []
