AB = Artificial.Babel
AT = Artificial.Telepathy

class AB.Server extends AT.RemoteServer
  constructor: ->
    super

    self = @

    # Make an instance of Translation that is connected to this server.
    class ArtificialBabelTranslation extends AB.Translation
      @Meta
        name: 'ArtificialBabelTranslation'
        server: self

    @Translation = ArtificialBabelTranslation

    # Define client-side method stubs.
    methods = AB.Translation.methods @connection, @Translation.documents
    @connection.methods methods

  # General translations

  # Subscribe to a namespace.
  subscribeNamespace: (namespace) ->
    subscriptionHandle = new @constructor.SubscriptionHandle namespace

    # Reactively subscribe to the translations so that we get updates when user's language preference changes.
    subscriptionHandle._babelSubscriptionAutorun = Meteor.autorun =>
      # Namespace is the component name.
      languages = AB.userLanguagePreference()

      # Save the handle so we can check its ready state before trying to insert keys into the database.
      subscriptionHandle._babelSubscriptionHandle = @subscribe 'Artificial.Babel.translations', namespace, null, languages

    subscriptionHandle

  # Main translation entry point. It tries to find a translation and inserts it if it's not present.
  translation: (handle, key) ->
    throw new Meteor.Error 'argument-null', "Subscription handle must be provided." unless handle?
    throw new Meteor.Error 'argument-null', "Key must be provided." unless key?

    translation = @Translation.documents.findOne
      namespace: handle.namespace
      key: key

    return translation if translation

    # If the subscription is ready and we haven't received a
    # translation, it must have not been added to the database yet.
    if handle._babelSubscriptionHandle.ready()
      # Looks like we'll need to insert it.
      @call 'Artificial.Babel.translationInsert', handle.namespace, key

    # Return null, The method will then repeat when the query above returns a document from the database.
    null

  translate: (namespace, key) ->
    translation = @translation namespace, key
    @constructor.translate translation, key

  # Components

  # Subscribe to a namespace using the target component.
  subscribeComponent: (component) ->
    # Reactively subscribe to the translations so that we get updates when user's language preference changes.
    component._babelSubscriptionAutorun = component.autorun =>
      # Namespace is the component name by default.
      namespace = component.babelNamespace or component.componentName()
      return unless namespace

      languages = AB.userLanguagePreference()

      # Save the handle on component so we can check its ready state before trying to insert keys into the database.
      component._babelSubscriptionHandle = @subscribe 'Artificial.Babel.translations', namespace, null, languages

  # Cleans up the subscription to this component's namespace.
  unsubscribeComponent: (component) ->
    component._babelSubscriptionAutorun.stop()
    component._babelSubscriptionHandle?.stop()

  # Main translation entry point for components. It tries to find a translation and inserts it if it's not present.
  translationForComponent: (component, key) ->
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
      @call 'Artificial.Babel.translationInsert', namespace, key

    # Return null, The method will then repeat when the query above returns a document from the database.
    null

  translateForComponent: (component, key) ->
    @constructor.translate @translationForComponent component, key

  @translate: (translation, key) ->
    return translation.translate AB.userLanguagePreference() if translation

    # If we don't have a translation for this yet, just return the key.
    text: key
    language: null

class AB.Server.SubscriptionHandle
  constructor: (@namespace) ->

  stop: ->
    @_babelSubscriptionAutorun.stop()
    @_babelSubscriptionHandle.stop()

# Create the default server on default connection.
if Meteor.isClient
  Meteor.startup ->
    AB.server = new AB.Server Meteor.connection
