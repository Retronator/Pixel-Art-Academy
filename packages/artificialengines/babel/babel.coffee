AE = Artificial.Everywhere

class Artificial.Babel
  # Default language when new translations are inserted.
  @defaultLanguage: 'en-US'

  @LanguagePreferenceLocalStorageKey:  "Artificial.Babel.languagePreference"

  # User's current language preference setting.
  @_userLanguagePreference: new ReactiveField null

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
  @subscribeNamespace: (namespace) ->
    subscriptionHandle = new @SubscriptionHandle namespace

    # Reactively subscribe to the translations so that we get updates when user's language preference changes.
    subscriptionHandle._babelSubscriptionAutorun = Meteor.autorun =>
      # Namespace is the component name.
      languages = @userLanguagePreference()

      # Save the handle so we can check its ready state before trying to insert keys into the database.
      subscriptionHandle._babelSubscriptionHandle = Meteor.subscribe 'Artificial.Babel.Translation', namespace, null, languages

    subscriptionHandle

  # Main translation entry point. It tries to find a translation and inserts it if it's not present.
  @translation: (handle, key) ->
    throw new AE.ArgumentNullException "Subscription handle must be provided." unless handle?
    throw new AE.ArgumentNullException "Key must be provided." unless key?

    translation = @Translation.documents.findOne
      namespace: handle.namespace
      key: key

    return translation if translation

    # If the subscription is ready and we haven't received a
    # translation, it must have not been added to the database yet.
    if handle._babelSubscriptionHandle.ready()
      # Looks like we'll need to insert it.
      Meteor.call 'Artificial.Babel.translationInsert', handle.namespace, key

    # Return null, The method will then repeat when the query above returns a document from the database.
    null

  # Creates a new translation with the default text or updates it if it
  # already exists. It returns the id of the new or existing translation.
  @createTranslation: (namespace, key, defaultText) ->
    existing = @Translation.documents.findOne
      namespace: namespace
      key: key

    if existing
      Meteor.call 'Artificial.Babel.translationUpdate', existing._id, @defaultLanguage, defaultText
      existing._id

    else
      Meteor.call 'Artificial.Babel.translationInsert', namespace, key, defaultText

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
      component._babelSubscriptionHandle = Meteor.subscribe 'Artificial.Babel.Translation', namespace, null, languages

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
      Meteor.call 'Artificial.Babel.translationInsert', namespace, key

    # Return null, The method will then repeat when the query above returns a document from the database.
    null

  @translateForComponent: (component, key) ->
    @translate @translationForComponent component, key

  @translate: (translationOrHandle, key) ->
    if translationOrHandle instanceof @SubscriptionHandle
      translation = @translation translationOrHandle, key

    else
      translation = translationOrHandle

    return translation.translate @userLanguagePreference() if translation

    # If we don't have a translation for this yet, just return the key.
    text: key
    language: null
