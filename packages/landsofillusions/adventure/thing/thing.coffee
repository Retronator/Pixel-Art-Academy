AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Thing extends AM.Component
  template: -> 'LandsOfIllusions.Adventure.Thing'
  # Static thing properties and methods

  # Id string for this thing used to identify the thing in code.
  @id: -> throw new Meteor.Error 'unimplemented', "You must specify thing's id."

  # The URL at which the thing is accessed.
  @url: -> throw new Meteor.Error 'unimplemented', "You must specify thing's url."

  # Generates the parameters object that can be passed to the router to get to this thing URL.
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

  # The long name is displayed to succinctly describe the thing. Btw, we can't just use 'name'
  # instead of 'shortName' because name gets overriden by CoffeeScript with the class name.
  @fullName: -> throw new Meteor.Error 'unimplemented', "You must specify thing's full name."

  # The short name of the thing which appears in possible exits. Default (null)
  # means a hidden thing that can only be accessed by its url. 
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
    # Store thing class by map and ID.
    @_thingClassesByUrl[@url()] = @
    @_thingClassesByID[@id()] = @

    # On the server, create translations.
    if Meteor.isServer
      for translationKey of @translationKeys
        defaultText = @[translationKey]()
        if defaultText
          namespace = @id()
          AB.createTranslation namespace, translationKey, defaultText

  # Thing instance

  constructor: (@options) ->
    super

    @adventure = @options.adventure

    # Subscribe to this thing's translations.
    translationNamespace = @constructor.id()
    @_translationSubscribtion = AB.subscribeNamespace translationNamespace

  destroy: ->
    @_translationSubscribtion.stop()

  # Convenience methods for static properties.
  id: -> @constructor.id()

  # Translated strings.
  fullName: -> @_getTranslation @constructor.translationKeys.fullName
  shortName: -> @_getTranslation @constructor.translationKeys.shortName
  description: -> @_getTranslation @constructor.translationKeys.description

  _getTranslation: (key) ->
    translation = Artificial.Babel.translation @_translationSubscribtion, key
    return unless translation

    translation.translate Artificial.Babel.userLanguagePreference()

  ready: ->
    @_translationSubscribtion.ready()
