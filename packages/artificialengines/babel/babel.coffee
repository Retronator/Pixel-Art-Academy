AE = Artificial.Everywhere

class Artificial.Babel
  # Default language when new translations are inserted.
  @defaultLanguage: 'en-US'

  @LanguagePreferenceLocalStorageKey: "Artificial.Babel.languagePreference"

  # User's current language preference setting.
  @_userLanguagePreference: new ReactiveField null

  # Global toggle that turn translatables into editable inputs.
  @inTranslationMode: new ReactiveField false

  @userLanguagePreference: (value) ->
    if value
      @_userLanguagePreference value

      # Also write it to local storage.
      if Meteor.isClient
        encodedValue = EJSON.stringify value
        localStorage.setItem @LanguagePreferenceLocalStorageKey, encodedValue

    @_userLanguagePreference()

  # Handle for keeping tracks of individual translation subscriptions.
  class @SubscriptionHandle
    constructor: (@namespace) ->

    ready: ->
      @_babelSubscriptionHandle.ready()

    stop: ->
      @_babelSubscriptionAutorun.stop()
      @_babelSubscriptionHandle.stop()

  # Subscribe to a namespace.
  @subscribeNamespace: (namespace, languages) ->
    subscriptionHandle = new @SubscriptionHandle namespace

    # Reactively subscribe to the translations so that we get updates when user's language preference changes.
    subscriptionHandle._babelSubscriptionAutorun = Tracker.autorun =>
      # We allow sending null as the languages if we want to subscribe to all languages.
      languages = @userLanguagePreference() if languages is undefined

      # Save the handle so we can check its ready state before trying to insert keys into the database.
      subscriptionHandle._babelSubscriptionHandle = @Translation.forNamespace.subscribe namespace, null, languages

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

  # Creates a new translation with the default text or updates it if it
  # already exists. It returns the id of the new or existing translation.
  @createTranslation: (namespace, key, defaultText) ->
    existing = @Translation.documents.findOne
      namespace: namespace
      key: key

    if existing
      Artificial.Babel.Translation.update existing._id, @defaultLanguage, defaultText if defaultText

      existing._id

    else
      Artificial.Babel.Translation.insert namespace, key, defaultText

  # Returns a translation that has already been created.
  @existingTranslation: (handle, key) ->
    throw new AE.ArgumentNullException "Subscription handle must be provided." unless handle?
    throw new AE.ArgumentNullException "Key must be provided." unless key?

    @Translation.documents.findOne
      namespace: handle.namespace
      key: key

  @translate: (translationOrHandle, key) ->
    if translationOrHandle instanceof @SubscriptionHandle
      translation = @existingTranslation translationOrHandle, key

    else
      translation = translationOrHandle

    return translation.translate @userLanguagePreference() if translation

    # If we don't have a translation for this yet, just return the key.
    text: key
    language: null

  # Components

  # Subscribe to a namespace using the target component.
  @subscribeComponent: (component) ->
    # Reactively subscribe to the translations so that we get updates when user's language preference changes.
    component._babelSubscriptionAutorun = component.autorun =>
      # Namespace is the component name by default.
      namespace = component.babelNamespace or component.componentName()
      return unless namespace

      languages = @userLanguagePreference()

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

    translation = @Translation.documents.findOne
      namespace: namespace
      key: key

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
