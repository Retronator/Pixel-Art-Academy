AE = Artificial.Everywhere
AEt = Artificial.Everything
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary

class LOI.Adventure.Thing extends AM.Component
  # Things should support aggregation.
  _.inherit @, AEt.Item

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
  @fullName: -> throw new AE.NotImplementedException "You must specify full name for thing #{@id()}."

  # The short name of the thing which is used to refer to it in the text. 
  @shortName: -> @fullName()

  # This sets how this thing's name should be corrected when not spelled correctly. 
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Word

  # Common nouns are allowed to chance capitalization to conform to sentence case. Proper nouns always stay unmodified.
  @nameNounType: -> LOI.Avatar.NameNounType.Common

  # The description text displayed in the interface. Default (null) means no longer descriptive name.
  @descriptiveName: -> null

  # The description text displayed when you look at the thing. Default (null) means no description.
  @description: -> null

  # Text transform for dialog lines delivered by this avatar.
  @dialogTextTransform: -> LOI.Avatar.DialogTextTransform.Auto
    
  # How this thing delivers dialog, used by the interface to format it appropriately.
  @dialogueDeliveryType: -> LOI.Avatar.DialogueDeliveryType.Saying

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

  @getClasses: ->
    _.values @_thingClassesById

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

  @getServerTranslations: (languagePreference) ->
    translationNamespace = @id()

    translations = {}

    for translationKey, defaultText of @_translations()
      translation = AB.Translation.documents.findOne
        namespace: translationNamespace
        key: translationKey

      translations[translationKey] = translation.translate(languagePreference).text

    translations

  @accessRequirement: -> # Override to set an access requirement to use this thing.

  @illustration: ->
    # Override to provide information about the illustration for this thing. By default there is no illustration data.
    null

  @initialize: ->
    # Store thing class by ID and url.
    @_thingClassesById[@id()] ?= @

    url = @url()
    if url?
      # See if we have a wildcard URL.
      if match = url.match /(.*)\/\*$/
        url = match[1]
        @_thingClassesByWildcardUrl[url] = @

      else
        @_thingClassesByUrl[url] = @

    # Prepare the avatar for this thing.
    LOI.Adventure.Thing.Avatar.initialize @

    # Prepare any extra translations.
    AB.Helpers.Translations.initialize @id(), @_translations()

    # Create static state field.
    @stateAddress = new LOI.StateAddress "things.#{@id()}"
    @state = new LOI.StateObject address: @stateAddress
    @readOnlyState = new LOI.StateObject address: @stateAddress, stateType: LOI.GameState.Type.ReadOnly

    @scriptStateAddress = new LOI.StateAddress "scripts.#{@id()}"
    @scriptState = new LOI.StateObject address: @scriptStateAddress

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
        @id: -> parentThing.defaultScriptId?() or parentThing.id()
        @initialize()
        initialize: ->
          # Make sure listener was not already destroyed while we were loading files.
          return if @options.listener._destroyed

          @options.parent.initializeScript.call @

      @avatars: -> parent.avatars()
      @initialize()

      startScript: (options) ->
        LOI.adventure.director.startScript @script, options

      startBackgroundScript: (options) ->
        LOI.adventure.director.startBackgroundScript @script, options

      onScriptsLoaded: ->
        defaultScriptId = @options.parent.constructor.defaultScriptId?() or @options.parent.id()
        @script = @scripts[defaultScriptId]
        @options.parent.onScriptsLoaded.call @

      onCommand: (commandResponse) -> @options.parent.onCommand.call @, commandResponse
      onChoicePlaceholder: (choicePlaceholderResponse) -> @options.parent.onChoicePlaceholder.call @, choicePlaceholderResponse
      onEnter: (enterResponse) ->
        # Automatically override the intro if it is provided.
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

      startScriptAtLatestCheckpoint: (checkpointLabels) ->
        @script.startAtLatestCheckpoint checkpointLabels

  @createAvatar: ->
    # Note: We fully qualify Avatar (instead of @Avatar) because this gets called from classes that inherit from Thing.
    new LOI.Adventure.Thing.Avatar @

  @reset: ->
    # Reset this thing's namespace.
    LOI.adventure.gameState.resetNamespaces [@id()]

  # Thing instance

  constructor: (@options) ->
    super arguments...

    # To improve component persistence (and ease debugging), we save the ID value as _id as well.
    @_id ?= @id()

    @avatar = @createAvatar()

    @state = @constructor.state
    @stateAddress = @constructor.stateAddress
    @readOnlyState = @constructor.readOnlyState

    @scriptState = @constructor.scriptState
    @scriptStateAddress = @constructor.scriptStateAddress

    # Provides support for autorun and subscribe calls even when component is not created.
    @_autorunHandles = []
    @_subscriptionHandles = []

    LOI.Adventure.initializeListenerProvider @
    
    @translations = new AB.Helpers.Translations @constructor.id()

    @thingReady = new ComputedField =>
      conditions = _.flattenDeep [
        @avatar.ready()
        listener.ready() for listener in @listeners
        @translations.ready()
      ]

      console.log "Thing ready?", @id(), conditions if LOI.debug

      _.every conditions

  destroy: ->
    @avatar.destroy()

    handle.stop() for handle in _.union @_autorunHandles, @_subscriptionHandles

    @translations.stop()
    @thingReady.stop()

    LOI.Adventure.destroyListenerProvider @

  # Convenience methods for static properties.
  id: -> @constructor.id()
  url: -> @constructor.url()
  illustration: -> @constructor.illustration()
  createAvatar: -> @constructor.createAvatar()

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
    return super(arguments...) if @isCreated()

    handle = Tracker.autorun handler
    @_autorunHandles.push handle

    handle

  # A variant of subscribe that works even when the component isn't being rendered.
  subscribe: (subscriptionName, params...) ->
    # If we're already created, we can simply use default implementation
    # that will stop the subscribe when component is removed from DOM.
    return super(arguments...) if @isCreated()

    handle = Meteor.subscribe subscriptionName, params...
    @_subscriptionHandles.push handle

    handle

  # A reactive field that can be used to query when a constructor has completed. Useful when you need to return the
  # value of some functions only after all the fields have been assigned in the constructor. Returns false until true
  # has been sent in the second parameter. The name can be used to distinguish between different constructors.
  constructed: (name, done) ->
    unless _.isString name
      done = name
      name = '_default'

    @_constructed ?= {}

    if done
      if @_constructed[name] is true
        console.error "Constructed called as done multiple times for same name", name
        return true

      dependency = @_constructed[name]

      # Mark that the constructor is done, so we can return true when queried from now on.
      # Dependency is no longer necessary since this is a one way operation.
      @_constructed[name] = true

      # Signal to all dependent callers that the change has occurred.
      dependency?.changed()

    else if @_constructed[name] is true
      # Simply return true.
      true

    else
      # Done hasn't been called yet for this name so we need to create a dependency for caller to be informed later.
      @_constructed[name] ?= new Tracker.Dependency
      @_constructed[name].depend()

      # Return false to indicate we're still waiting.
      false

  getListener: (listenerClass) ->
    _.find @listeners, (listener) -> listener instanceof listenerClass

  accessRequirement: -> @constructor.accessRequirement()
  meetsAccessRequirement: ->
    # If there is no access requirement, the conditions are met.
    return true unless accessRequirement = @accessRequirement()

    # We have some condition, so we need a user to pass.
    return false unless user = Retronator.user()

    # The requirement is met if the user has the required item.
    user.hasItem accessRequirement

  reset: ->
    @constructor.reset()

  # Avatar pass-through methods

  fullName: -> @avatar?.fullName()
  shortName: -> @avatar?.shortName()
  pronouns: -> @avatar?.pronouns()
  nameAutoCorrectStyle: -> @avatar?.nameAutoCorrectStyle()
  nameNounType: -> @avatar?.nameNounType()
  descriptiveName: -> @avatar?.descriptiveName()
  description: -> @avatar?.description()
  color: -> @avatar?.color()
  dialogTextTransform: -> @avatar?.dialogTextTransform()
  dialogueDeliveryType: -> @avatar?.dialogueDeliveryType()

  # Default listener handlers

  @scriptUrls: -> [] # Override to provide a list of script URLs to load.
  @avatars: -> {} # Override with a map of shorthands and thing classes for the things the listener needs to respond to.

  onScriptsLoaded: -> # Override to start reactive logic. Use @scripts to get access to script objects.
  onCommand: (commandResponse) -> # Override to listen to commands.
  onChoicePlaceholder: (choicePlaceholderResponse) -> # Override to insert choice nodes at the placeholder.
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
