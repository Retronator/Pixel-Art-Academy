AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary

class LOI.Adventure.Thing extends AM.Component
  template: -> 'LandsOfIllusions.Adventure.Thing'
    
  # Static thing properties and methods

  # A map of all thing constructors by url and ID.
  @_thingClassesByUrl = {}
  @_thingClassesByWildcardUrl = {}
  @_thingClassesById = {}

  # Id string for this thing used to identify the thing in code.
  @id: -> throw new AE.NotImplementedException "You must specify thing's id."

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

  # This sets how this thing's name should be corrected when not spelled correctly. 
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Word

  # The description text displayed when you look at the thing. Default (null) means no description.
  @description: -> null

  # Text transform for dialog lines delivered by this avatar.
  @dialogTextTransform: -> LOI.Avatar.DialogTextTransform.Auto
    
  # How this thing delivers dialog, used by the interface to format it appropriately.
  @dialogDeliveryType: -> LOI.Avatar.DialogDeliveryType.Saying

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

  # Override for listeners to be initialized when thing is created.
  @listeners: -> [
    @Listener
  ]

  @_translations: ->
    translations = @translations?() or {}

    intro = @intro?()
    translations.intro = intro if intro

    translations

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

    # On the server, prepare any extra translations.
    if Meteor.isServer
      translationNamespace = @id()

      for translationKey, defaultText of @_translations()
        AB.createTranslation translationNamespace, translationKey, defaultText if defaultText

    # Create static state field.
    @stateAddress = new LOI.StateAddress "things.#{@id()}"
    @state = new LOI.StateObject address: @stateAddress

    # Create default listener.
    parent = @

    class @Listener extends LOI.Adventure.Listener
      @id: -> "#{parent.id()}.Listener"

      @scriptUrls: ->
        urls = []

        url = parent.defaultScriptUrl?()
        urls.push url if url

        urls

      parentThing = parent
      class @Script extends LOI.Adventure.Script
        @id: -> parentThing.id()
        @initialize()
        initialize: -> @options.parent.initializeScript.call @

      @avatars: -> parent.avatars()
      @initialize()

      startScript: (options) ->
        LOI.adventure.director.startScript @script, options

      onScriptsLoaded: ->
        @script = @scripts[@options.parent.id()]
        @options.parent.onScriptsLoaded.call @

      onCommand: (commandResponse) -> @options.parent.onCommand.call @, commandResponse
      onEnter: (enterResponse) ->
        if @options.parent.constructor.intro
          enterResponse.overrideIntroduction =>
            @options.parent.translations()?.intro

        @options.parent.onEnter.call @, enterResponse

      onExitAttempt: (exitResponse) -> @options.parent.onExitAttempt.call @, exitResponse
      onExit: (exitResponse) -> @options.parent.onExit.call @, exitResponse
      cleanup: -> @options.parent.cleanup.call @

      # Sets things that have a shorthand name in the script, by pulling them from current things.
      setCurrentThings: (thingClasses, callback) ->
        Tracker.autorun (computation) =>
          things = {}
          for key, thingClass of thingClasses
            things[key] = LOI.adventure.getCurrentThing thingClass
            return unless things[key]?.ready()

          computation.stop()

          @script.setThings things

          Tracker.nonreactive => callback?()

  @createAvatar: ->
    new LOI.Avatar @

  # Thing instance

  constructor: (@options) ->
    super

    # To ease debugging, we save the ID value as a variable on the instance.
    @ID = @id()

    @avatar = @constructor.createAvatar()

    @state = @constructor.state
    @stateAddress = @constructor.stateAddress

    # Provides support for autorun and subscribe calls even when component is not created.
    @_autorunHandles = []
    @_subscriptionHandles = []

    LOI.Adventure.initializeListenerProvider @

    # Subscribe to this thing's translations.
    translationNamespace = @constructor.id()
    @_translationSubscription = AB.subscribeNamespace translationNamespace
    
    @translations = new ComputedField =>
      return unless @_translationSubscription.ready()

      translations = {}

      for translationKey, defaultText of @constructor._translations()
        translated = AB.translate @_translationSubscription, translationKey
        translations[translationKey] = translated.text if translated.language

      translations

    @thingReady = new ComputedField =>
      conditions = _.flattenDeep [
        @avatar.ready()
        listener.ready() for listener in @listeners
        @_translationSubscription.ready()
      ]

      console.log "Thing ready?", @id(), conditions if LOI.debug

      _.every conditions

  destroy: ->
    @avatar.destroy()

    handle.stop() for handle in _.union @_autorunHandles, @_subscriptionHandles

    @_translationSubscription.stop()

    @thingReady.stop()

    LOI.Adventure.destroyListenerProvider @

  # Convenience methods for static properties.
  id: -> @constructor.id()
  url: -> @constructor.url()

  # Override to control if the item appears in the interface.
  isVisible: -> true
  displayInLocation: -> @isVisible()
  displayInInventory: -> @isVisible()

  ready: ->
    @thingReady()

  # A variant of autorun that works even when the component isn't being rendered.
  autorun: (handler) ->
    # If we're already created, we can simply use default implementation
    # that will stop the autorun when component is removed from DOM.
    return super if @isCreated()

    handle = Tracker.autorun handler
    @_autorunHandles.push handle

    handle

  # A variant of subscribe that works even when the component isn't being rendered.
  subscribe: (subscriptionName, params...) ->
    # If we're already created, we can simply use default implementation
    # that will stop the subscribe when component is removed from DOM.
    return super if @isCreated()

    handle = Meteor.subscribe subscriptionName, params...
    @_subscriptionHandles.push handle

    handle

  # Avatar pass-through methods

  fullName: -> @avatar?.fullName()
  shortName: -> @avatar?.shortName()
  nameAutoCorrectStyle: -> @avatar?.nameAutoCorrectStyle()
  description: -> @avatar?.description()
  color: -> @avatar?.color()
  dialogTextTransform: -> @avatar?.dialogTextTransform()
  dialogDeliveryType: -> @avatar?.dialogDeliveryType()

  # Default listener handlers

  @scriptUrls: -> [] # Override to provide a list of script URLs to load.
  @avatars: -> {} # Override with a map of shorthands and thing classes for the things the listener needs to respond to.

  onScriptsLoaded: -> # Override to start reactive logic. Use @scripts to get access to script objects.
  onCommand: (commandResponse) -> # Override to listen to commands.
  onEnter: (enterResponse) -> # Override to react to entering a location.
  onExitAttempt: (exitResponse) -> # Override to react to location change attempts, potentially preventing the exit.
  onExit: (exitResponse) ->
    # Override to react to leaving a location.
    @cleanup()
  cleanup: -> # Override to clean any timers or autoruns that need to be cleaned when listener exits or is destroyed.

  # Default script handlers

  initializeScript: -> # Override to setup the script on the client.

  # Debug

  @typeName: -> 'LOI.Adventure.Thing'
  typeName: -> @constructor.typeName()

  toString: ->
    "#{@typeName()}{#{@id()}}"
