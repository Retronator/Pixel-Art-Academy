AE = Artificial.Everywhere
AB = Artificial.Babel

AB.Translation.insert.method (namespace, key, defaultText) ->
  check namespace, String
  check key, String
  check defaultText, Match.OptionalOrNull String

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
    AB.Translation.update translationId, Artificial.Babel.defaultLanguage, text

  # Return the id of the new translation.
  translationId

AB.Translation.update.method (translationId, language, text) ->
  check translationId, Match.DocumentId
  check language, String
  check text, String

  translation = AB.Translation.documents.findOne translationId

  unless translation
    # On the client it's OK if we don't have a translation (it might have been embedded in another document).
    return if Meteor.isClient

    # On the server, throw an error on missing translations.
    throw new AE.ArgumentException "Translation does not exist."

  languageProperty = language.toLowerCase().replace '-', '.'

  set = {}

  # Override the translation.
  set["translations.#{languageProperty}.text"] = text

  # Reset the quality.
  set["translations.#{languageProperty}.quality"] = 0

  AB.Translation.documents.update translationId, $set: set

removeLanguage = (translations, language) ->
  {languageCode, regionCode} = _.splitLanguageRegion language

  languageData = translations[languageCode]

  if regionCode
    # When deleting a region, we can delete the whole node.
    delete languageData[regionCode]

  else
    languageRegions = _.without(_.keys(languageData), ['text', 'quality', 'meta'])
    if languageRegions.length
      # We have region translations, so just delete the translation set in the language node.
      delete languageData.text
      delete languageData.quality
      delete languageData.meta

    else
      # There are no region translations, we can delete the whole language node.
      delete translations[languageCode]

AB.Translation.remove.method (translationId, language) ->
  check translationId, Match.DocumentId
  check language, String

  translation = AB.Translation.documents.findOne translationId

  unless translation
    # On the client it's OK if we don't have a translation (it might have been embedded in another document).
    return if Meteor.isClient

    # On the server, throw an error on missing translations.
    throw new AE.ArgumentException "Translation does not exist."

  removeLanguage translation.translations, language

  AB.Translation.documents.update translationId,
    $set:
      translations: translation.translations

AB.Translation.move.method (translationId, oldLanguage, newLanguage) ->
  check translationId, Match.DocumentId
  check oldLanguage, String
  check newLanguage, String

  translation = AB.Translation.documents.findOne translationId

  unless translation
    # On the client it's OK if we don't have a translation (it might have been embedded in another document).
    return if Meteor.isClient

    # On the server, throw an error on missing translations.
    throw new AE.ArgumentException "Translation does not exist."

  oldLanguageProperty = oldLanguage.toLowerCase().replace '-', '.'
  newLanguageProperty = newLanguage.toLowerCase().replace '-', '.'

  oldTranslationData = _.nestedProperty translation.translations, oldLanguageProperty
  throw new AE.ArgumentException "Old language doesn't have a translation." unless oldTranslationData

  removeLanguage translation.translations, oldLanguage

  newTranslationData = _.nestedProperty(translation.translations, newLanguageProperty) or {}

  # Move the old data to new data.
  _.extend newTranslationData, oldTranslationData

  _.nestedProperty translation.translations, newLanguageProperty, newTranslationData

  AB.Translation.documents.update translationId,
    $set:
      translations: translation.translations
