AB = Artificial.Babel

AB.Translation.methods = (connection, documents) ->
  'Artificial.Babel.translationInsert': (namespace, key) ->
    check namespace, String
    check key, String

    # Ensure namespace and key are unique.
    existing = documents.findOne
      namespace: namespace
      key: key

    throw new Meteor.Error 'invalid-argument', "Namespace-key pair must be unique." if existing

    translationId = documents.insert
      namespace: namespace
      key: key

    if Meteor.isServer
      # See if we should insert the key as the translation for the default language.
      if Artificial.Babel.insertKeyForDefaultLanguage
        connection.call 'Artificial.Babel.translationUpdate', translationId, Artificial.Babel.defaultLanguage, key

    # Return the id of the new translation.
    translationId

  'Artificial.Babel.translationUpdate': (translationId, language, text) ->
    check translationId, Match.DocumentId
    check language, String
    check text, String

    # Ensure namespace and key are unique.
    translation = documents.findOne translationId
    throw new Meteor.Error 'not-found', "Translation does not exist." unless translation

    languageProperty = language.replace '-', '.'

    set = {}

    # Override the translation.
    set["translations.#{languageProperty}.text"] = text

    # Reset the quality.
    set["translations.#{languageProperty}.quality"] = 0

    documents.update translationId, $set: set

# On the server, also serve the methods.
if Meteor.isServer
  # Simply pass Meteor as the connection (the object on which to call server methods).
  methods = AB.Translation.methods Meteor, AB.Translation.documents
  Meteor.methods methods
