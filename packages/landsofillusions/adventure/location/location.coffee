AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Location extends AM.Component
  template: -> 'LandsOfIllusions.Adventure.Location'

  constructor: ->
    super
    
    @exits = new ReactiveField {}

    @director = new LOI.Adventure.Director @
    @actors = new ReactiveField []

    # Subscribe to this location's translations.
    translationNamespace = @constructor.id()
    @_translationSubscribtion = AB.subscribeNamespace translationNamespace

    # Also subscribe to translations of exit locations so we get their names.
    @exitsTranslationSubscribtions = {}
    @_exitsTranslationsAutorun = Tracker.autorun (computation) =>
      for directionKey, locationId of @exits()
        @exitsTranslationSubscribtions[locationId] = AB.subscribeNamespace locationId

    # Subscribe to this location's script translations.
    translationNamespace = @constructor.id()
    @_translationSubscribtionScript = AB.subscribeNamespace "#{translationNamespace}.Script"

    # Create the scripts.
    @scriptNodes = {}
    if @constructor.scriptUrls
      scripts = for scriptUrl in @constructor.scriptUrls()
        LOI.Adventure.Script.load "/packages/#{scriptUrl}"

      Promise.all(scripts).then (scripts) =>
        console.log "got results", scripts
        for scriptNodes in scripts
          # Because we're on the client, we need to replace text with translations.
          LOI.Adventure.Script.translate @constructor.id(), scriptNodes

          # Add the loaded and translated script nodes to this location.
          _.extend @scriptNodes, scriptNodes

        @onScriptsLoaded()

  destroy: ->
    @_translationSubscribtion.stop()

    @_exitsTranslationsAutorun.stop()
    @exitsTranslationSubscribtions = null

    @_translationSubscribtionScript.stop()

  ready: ->
    @_translationSubscribtion.ready()

  onScriptsLoaded: -> # Override to create location's script logic. Use @scriptNodes to get access to script nodes.

  addExit: (directionKey, locationId) ->
    exits = @exits()
    exits[directionKey] = locationId
    @exits exits

  addActor: (actor) ->
    actor.director @director
    @actors @actors().concat actor

    # Allow chaining syntax
    actor

  # Static location properties and methods

  # Id string for this location used to identify the location in code.
  @id: -> throw new Meteor.Error 'unimplemented', "You must specify location's id."

  # The URL at which the location is accessed.
  @url: -> throw new Meteor.Error 'unimplemented', "You must specify location's url."

  # Generates the parameters object that can be passed to the router to get to this location URL.
  @urlParameters: ->
    # Split URL into object with parameter properties.
    urlParameters = @url().split('/')

    parametersObject = {}

    for urlParameter, i in urlParameters
      parametersObject["parameter#{i + 1}"] = urlParameter

    parametersObject

  @translationKeys:
    fullName: 'fullName'
    shortName: 'shortName'
    description: 'description'

  # The long name is displayed to succinctly describe the location. Btw, we can't just use 'name'
  # instead of 'shortName' because name gets overriden by CoffeeScript with the class name.
  @fullName: -> throw new Meteor.Error 'unimplemented', "You must specify location's full name."
  fullName: -> @_getTranslation @constructor.translationKeys.fullName

  # The short name of the location which appears in possible exits. Default (null)
  # means a hidden location that can only be accessed by its url. 
  @shortName: -> null
  shortName: -> @_getTranslation @constructor.translationKeys.shortName

  # The description text displayed when you enter the location for the first time or specifically look around. Default
  # (null) means no description.
  @description: -> null
  description: -> @_getTranslation @constructor.translationKeys.description

  # The maximum height of location's illustration. By default there is no illustration (height 0).
  @illustrationHeight: -> 0
  illustrationHeight: -> @constructor.illustrationHeight()

  # A map of all location constructors separated into nested objects by their url path.
  @_locationClassesByUrlPath = {}
  @getClassForPath: (path) ->
    _.nestedProperty @_locationClassesByUrlPath, "#{path}._class"

  @_locationClassesByID = {}
  @getClassForID: (id) ->
    @_locationClassesByID[id]

  @initialize: ->
    # Store location class into locations broken down by its url.
    path = @url().replace(/\//g, '.')
    _.nestedProperty @_locationClassesByUrlPath, "#{path}._class", @

    # Do the same for the ID map.
    @_locationClassesByID[@id()] = @

    # On the server, create translations.
    if Meteor.isServer
      for translationKey of @translationKeys
        defaultText = @[translationKey]()
        @_createTranslation translationKey, defaultText if defaultText

    # On the server, compile the scripts.
    if Meteor.isServer and @scriptUrls
      for scriptUrl in @scriptUrls()
        [packageId, urlParts...] = scriptUrl.split '/'
        url = urlParts.join '/'
        text = LOI.packages[packageId].assets.getText url
        LOI.Adventure.Script.initialize @id(), text

  @_createTranslation: (key, defaultText) ->
    namespace = @id()
    AB.createTranslation namespace, key, defaultText

  _getTranslation: (key) ->
    translation = Artificial.Babel.translation @_translationSubscribtion, key
    return unless translation

    translation.translate Artificial.Babel.userLanguagePreference()
