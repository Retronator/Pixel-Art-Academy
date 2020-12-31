AE = Artificial.Everywhere
AB = Artificial.Babel

AB.Translation.insert.method (namespace, key, defaultText) ->
  check namespace, String
  check key, String
  check defaultText, Match.OptionalOrNull String

  # TODO: Allow creation of translations only for admins and translators.
  AB.Translation._insert namespace, key, defaultText

# We separate the actual body of the method so we can call it on the server without error checking
# (for when the server needs to create translations for users that don't otherwise have permissions).
AB.Translation._insert = (namespace, key, defaultText) ->
  # Ensure namespace and key are unique.
  existing = AB.Translation.documents.findOne
    namespace: namespace
    key: key

  if existing
    throw new AE.ArgumentException "Namespace-key pair must be unique. (namespace: #{namespace}, key: #{key}, default text: #{defaultText})"

  translationId = AB.Translation.documents.insert
    namespace: namespace
    key: key
    lastEditTime: new Date

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

  # TODO: Allow updating translations only for admins, translators and translation owner.
  AB.Translation._update translationId, language, text

# We separate the actual body of the method so we can call it on the server without error checking
# (for when the server needs to create translations for users that don't otherwise have permissions).
AB.Translation._update = (translationId, language, text) ->
  translation = AB.Translation.documents.findOne translationId

  unless translation
    # On the client it's OK if we don't have a translation (it might have been embedded in another document).
    return if Meteor.isClient

    # On the server, throw an error on missing translations.
    throw new AE.ArgumentException "Translation does not exist.", translationId

  languageProperty = language.toLowerCase().replace '-', '.'

  # Create translations if this is the first update.
  translation.translations ?= {}

  if languageProperty.length
    languageData = _.nestedProperty translation.translations, languageProperty

    unless languageData
      # If this is a new translation, create its node.
      languageData = {}
      _.nestedProperty translation.translations, languageProperty, languageData

  else
    # We are updating the global, language-agnostic translation.
    languageData = translation.translations

  # Override the translation.
  languageData.text = text

  # Reset the quality.
  languageData.quality = 0

  translation.generateBestTranslations()

  AB.Translation.documents.update translationId,
    $set:
      translations: translation.translations
      lastEditTime: new Date

AB.Translation.remove.method (translationId) ->
  check translationId, Match.DocumentId

  # TODO: Allow removal of translations only for admins.
  AB.Translation._remove translationId

# We separate the actual body of the method so we can call it on the server without error checking
# (for when the server needs to create translations for users that don't otherwise have permissions).
AB.Translation._remove = (translationId) ->
  # Ensure namespace and key are unique.
  existing = AB.Translation.documents.findOne translationId

  unless existing
    # On the client it's OK if we don't have a translation (it might have been embedded in another document).
    return if Meteor.isClient

    # On the server, throw an error on missing translations.
    throw new AE.ArgumentException "Translation does not exist."

  AB.Translation.documents.remove translationId

removeLanguage = (translations, language) ->
  {languageCode, regionCode} = _.splitLanguageRegion language

  if languageCode
    languageData = translations[languageCode]
    # See if there is even anything to do.
    return unless languageData

    if regionCode
      # See if there is even anything to do.
      return unless languageData[regionCode]

      # When deleting a region, we can delete the whole node.
      delete languageData[regionCode]

      # See if there are any other regions left in the language.
      languageRegions = _.filter _.keys(languageData), (key) => key.length is 2

      unless languageRegions.length
        # There are no region translations anymore, we can delete the whole language node.
        delete translations[languageCode]

    else
      # See if we have any language regions (those with 2 characters).
      languageRegions = _.filter _.keys(languageData), (key) => key.length is 2

      if languageRegions.length
        # We have region translations, so just delete the translation set in the language node.
        delete languageData.text
        delete languageData.quality
        delete languageData.meta

      else
        # There are no region translations, we can delete the whole language node.
        delete translations[languageCode]

  else
    # When deleting the global translation, we just delete the fields.
    delete translations.text
    delete translations.quality
    delete translations.meta

AB.Translation.removeLanguage.method (translationId, language) ->
  check translationId, Match.DocumentId
  check language, String

  # TODO: Allow updating translations only for admins and translators.
  AB.Translation._removeLanguage translationId, language

# We separate the actual body of the method so we can call it on the server without error checking
# (for when the server needs to create translations for users that don't otherwise have permissions).
AB.Translation._removeLanguage = (translationId, language) ->
  translation = AB.Translation.documents.findOne translationId

  unless translation
    # On the client it's OK if we don't have a translation (it might have been embedded in another document).
    return if Meteor.isClient

    # On the server, throw an error on missing translations.
    throw new AE.ArgumentException "Translation does not exist."

  removeLanguage translation.translations, language

  translation.generateBestTranslations()

  AB.Translation.documents.update translationId,
    $set:
      translations: translation.translations
      lastEditTime: new Date

AB.Translation.moveLanguage.method (translationId, oldLanguage, newLanguage) ->
  check translationId, Match.DocumentId
  check oldLanguage, String
  check newLanguage, String

  # TODO: Allow updating translations only for admins and translators.
  AB.Translation._moveLanguage translationId, oldLanguage, newLanguage

# We separate the actual body of the method so we can call it on the server without error checking
# (for when the server needs to create translations for users that don't otherwise have permissions).
AB.Translation._moveLanguage = (translationId, oldLanguage, newLanguage) ->

  translation = AB.Translation.documents.findOne translationId

  unless translation
    # On the client it's OK if we don't have a translation (it might have been embedded in another document).
    return if Meteor.isClient

    # On the server, throw an error on missing translations.
    throw new AE.ArgumentException "Translation does not exist."

  oldLanguageProperty = oldLanguage.toLowerCase().replace '-', '.'
  newLanguageProperty = newLanguage.toLowerCase().replace '-', '.'

  if oldLanguageProperty.length
    oldTranslationData = _.nestedProperty translation.translations, oldLanguageProperty

  else
    oldTranslationData = translation.translations

  throw new AE.ArgumentException "Old language doesn't have a translation." unless oldTranslationData

  # Clone translation data.
  translationData =
    text: oldTranslationData.text
    quality: oldTranslationData.quality
    meta: oldTranslationData.meta

  removeLanguage translation.translations, oldLanguage

  if newLanguageProperty.length
    newTranslationData = _.nestedProperty(translation.translations, newLanguageProperty) or {}

  else
    newTranslationData = translation.translations or {}

  # Move the old data to new data.
  _.extend newTranslationData, translationData

  if newLanguageProperty.length
    _.nestedProperty translation.translations, newLanguageProperty, newTranslationData

  else
    translation.translations = newTranslationData

  translation.generateBestTranslations()

  AB.Translation.documents.update translationId,
    $set:
      translations: translation.translations
      lastEditTime: new Date
