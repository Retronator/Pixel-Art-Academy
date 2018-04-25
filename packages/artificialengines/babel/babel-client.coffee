AE = Artificial.Everywhere

class Artificial.Babel extends Artificial.Babel
  # User's current language preference setting.
  @_userLanguagePreference: new ReactiveField null

  # Global toggle that turns translatables into editable inputs.
  @inTranslationMode: new ReactiveField false

  @languagePreference: (value) ->
    if value
      @_userLanguagePreference value

    @_userLanguagePreference()
    
  # Load cache.
  @_cache = new ReactiveField null

  HTTP.get @cacheUrl, (error, response) =>
    @_cache JSON.parse response.content

  # Handle for keeping tracks of individual translation subscriptions.
  class @SubscriptionHandle
    constructor: (@namespace) ->

    ready: ->
      if Artificial.Babel.inTranslationMode()
        @_babelSubscriptionHandle.ready()

      else
        Artificial.Babel._cache()?

    stop: ->
      @_babelSubscriptionAutorun.stop()
      @_babelSubscriptionHandle?.stop()

  # Subscribe to a namespace.
  @subscribeNamespace: (namespace, options = {}) ->
    subscriptionHandle = new @SubscriptionHandle namespace

    # Reactively subscribe to the translations so that we get updates when user's language preference changes.
    subscriptionHandle._babelSubscriptionAutorun = Tracker.autorun =>
      # No need to subscribe unless we're in translation mode.
      return unless @inTranslationMode()

      # We allow sending null as the languages if we want to subscribe to all languages.
      languages = options.languages ? @languagePreference()

      subscribeProvider = options.subscribeProvider or Meteor

      # Save the handle so we can check its ready state before trying to insert keys into the database.
      subscriptionHandle._babelSubscriptionHandle = @Translation.forNamespace.subscribe subscribeProvider, namespace, null, languages

    subscriptionHandle

  # Main translation entry point. It tries to find a translation and inserts it if it's not present.
  @translation: (handle, key) ->
    translation = @existingTranslation handle, key

    return translation if translation

    # If the subscription is ready and we haven't received a
    # translation, it must have not been added to the database yet.
    if handle._babelSubscriptionHandle.ready()
      # Looks like we'll need to insert it.
      Artificial.Babel.Translation.insert handle.namespace, key

    # Return null, The method will then repeat when the query above returns a document from the database.
    null

  # Returns a translation that has already been created.
  @existingTranslation: (handleOrNamespace, key) ->
    throw new AE.ArgumentNullException "Subscription handle or namespace must be provided." unless handleOrNamespace?
    throw new AE.ArgumentNullException "Key must be provided." unless key?

    namespace = handleOrNamespace.namespace or handleOrNamespace

    if @inTranslationMode()
      @Translation.documents.findOne
        namespace: namespace
        key: key

    else
      return unless cachedTranslation = @_cache()?[namespace]?[key]

      # Get translation from cache.
      new @Translation
        _id: cachedTranslation[0]
        namespace: namespace
        key: key
        translations: cachedTranslation[1]

  # Returns a translation that has already been created.
  @existingTranslations: (handleOrNamespace, keyRegex) ->
    throw new AE.ArgumentNullException "Subscription handle or namespace must be provided." unless handleOrNamespace?
    keyRegex ?= /.*/

    namespace = handleOrNamespace.namespace or handleOrNamespace

    if @inTranslationMode()
      @Translation.documents.fetch
        namespace: namespace
        key:
          $regex: keyRegex

    else
      return [] unless cache = @_cache()
      return [] unless cache[namespace]

      for key, translations of cache[namespace] when keyRegex.test key
        new @Translation
          _id: translations?[0]
          namespace: namespace
          key: key
          translations: translations?[1]

  @translate: (translationOrHandle, key) ->
    if translationOrHandle instanceof @SubscriptionHandle
      translation = @existingTranslation translationOrHandle, key

    else
      translation = translationOrHandle

    return translation.translate @languagePreference() if translation

    # If we don't have a translation for this yet, just return the key.
    text: key
    language: null

  # Components

  # Subscribe to a namespace using the target component.
  @subscribeComponent: (component) ->
    # Reactively subscribe to the translations so that we get updates when user's language preference changes.
    component._babelSubscriptionAutorun = component.autorun =>
      # No need to subscribe unless we're in translation mode.
      return unless @inTranslationMode()

      # Namespace is the component name by default.
      namespace = component.babelNamespace or component.componentName()
      return unless namespace

      languages = @languagePreference()

      # Save the handle on component so we can check its ready state before trying to insert keys into the database.
      component._babelSubscriptionHandle = @Translation.forNamespace.subscribe namespace, null, languages

  # Cleans up the subscription to this component's namespace.
  @unsubscribeComponent: (component) ->
    component._babelSubscriptionAutorun.stop()
    component._babelSubscriptionHandle?.stop()

  # Main translation entry point for components. It tries to find a translation and inserts it if it's not present.
  @translationForComponent: (component, key) ->
    throw new Meteor.Error 'argument-null', "Component must be provided." unless component?
    throw new Meteor.Error 'argument-null', "Key must be provided." unless key?

    namespace = component.componentName()

    if @inTranslationMode()
      translation = @Translation.documents.findOne
        namespace: namespace
        key: key

    else
      # Get translation from cache.
      cache = @_cache()

      return unless cachedTranslation = cache?[namespace]?[key]

      translation = new @Translation
        _id: cachedTranslation[0]
        namespace: namespace
        key: key
        translations: cachedTranslation[1]

    return translation if translation

    # If the subscription is ready and we haven't received a
    # translation, it must have not been added to the database yet.
    if component._babelSubscriptionHandle.ready()
      # Looks like we'll need to insert it.
      Artificial.Babel.Translation.insert namespace, key

    # Return null, The method will then repeat when the query above returns a document from the database.
    null

  @translateForComponent: (component, key) ->
    @translate @translationForComponent(component, key), key
