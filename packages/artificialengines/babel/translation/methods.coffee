AE = Artificial.Everywhere
AB = Artificial.Babel

Meteor.methods
  'Artificial.Babel.translationInsert': (namespace, key, defaultText) ->
    check namespace, String
    check key, String

    # Ensure namespace and key are unique.
    existing = AB.Translation.documents.findOne
      namespace: namespace
      key: key

    if existing
      throw new AE.ArgumentException "Namespace-key pair must be unique. (namespace: #{namespace}, key: #{key}, default text: #{defaultText})"

    translationId = AB.Translation.documents.insert
      namespace: namespace
      key: key

    if Meteor.isServer
      # Insert the provided default text or fall back to just the key.
      text = defaultText or key
      Meteor.call 'Artificial.Babel.translationUpdate', translationId, Artificial.Babel.defaultLanguage, text

    # Return the id of the new translation.
    translationId

  'Artificial.Babel.translationUpdate': (translationId, language, text) ->
    check translationId, Match.DocumentId
    check language, String
    check text, String

    translation = AB.Translation.documents.findOne translationId
    throw new Meteor.Error 'not-found', "Translation does not exist." unless translation

    languageProperty = language.toLowerCase().replace '-', '.'

    set = {}

    # Override the translation.
    set["translations.#{languageProperty}.text"] = text

    # Reset the quality.
    set["translations.#{languageProperty}.quality"] = 0

    AB.Translation.documents.update translationId, $set: set
