AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

Vocabulary = LOI.Adventure.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action
Talking = LOI.Adventure.Ability.Talking

class LOI.Adventure.Thing extends AM.Component
  template: -> 'LandsOfIllusions.Adventure.Thing'
    
  # Static thing properties and methods

  # A map of all location constructors by url and ID.
  @_thingClassesByUrl = {}
  @_thingClassesByID = {}

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
      parametersObject["parameter#{i + 1}"] = urlParameter

    parametersObject

  # The long name is displayed to succinctly describe the thing. Also, we can't just use 'name'
  # instead of 'fullName' because name gets overriden by CoffeeScript with the class name.
  @fullName: -> throw new Meteor.Error 'unimplemented', "You must specify thing's full name."

  # The short name of the thing which is used to refer to it in the text. 
  @shortName: -> null

  # The description text displayed when you enter the thing for the first time or specifically look around. Default
  # (null) means no description.
  @description: -> null

  # Helper methods to access class constructors.
  @getClassForUrl: (url) ->
    @_thingClassesByUrl[url]

  @getClassForID: (id) ->
    @_thingClassesByID[id]

  @initialize: ->
    # Store thing class by ID and url.
    @_thingClassesByID[@id()] = @
    @_thingClassesByUrl[@url()] = @ if @url()

    # Prepare the avatar for this thing.
    LOI.Avatar.initialize @

  # Thing instance

  constructor: (@options) ->
    super

    @avatar = new LOI.Avatar @constructor
    @abilities = new ReactiveField []
    @director = new ReactiveField null
    @state = new ReactiveField null

    @_autorunHandles = []
    @_subscriptionHandles = []

  destroy: ->
    @avatar.destroy()
    for ability in @abilities()
      # Break the two-way relationship and let the ability do any additional cleanup.
      ability.thing null
      ability.destroy()

    handle.stop() for handle in _.union @_autorunHandles, @_subscriptionHandles

  initialState: -> {} # Override to return a non-empty initial state.

  # Convenience methods for static properties.
  id: -> @constructor.id()

  ready: ->
    @avatar.ready()

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
  
  addAbilityLook: ->
    @addAbility new Action
      verb: Vocabulary.Keys.Verbs.Look
      action: =>
        LOI.Adventure.goToItem @constructor.id()

  # Helper to access running scripts.
  currentScripts: ->
    @director()?.currentScripts() or []
