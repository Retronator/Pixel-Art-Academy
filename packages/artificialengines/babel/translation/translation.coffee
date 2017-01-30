AE = Artificial.Everywhere
AB = Artificial.Babel
AT = Artificial.Telepathy
AM = Artificial.Mummification

class ArtificialBabelTranslation extends AM.Document
  # namespace: string name of related keys
  # key: English string that identifies this translation (namespace and key pair should be unique)
  # translations:
  #   {language}: two-character language code
  #     {region}: two-character region code
  #       text: translated text of the key
  #       quality: a number by which we can sort translations from different regions to find the best translation
  #       meta: TODO: information about the translation process, authors, revisions, voting etc.
  @Meta
    name: 'ArtificialBabelTranslation'

  # Helper method for quickly getting a translation. It's only particularly useful on the server where all the
  # translations are immediately accessible. On the client we need to subscribe to the translation documents first
  # without which this method will not return anything. Thus on the client you should work with helper methods on the
  # Artificial.Babel class directly.
  @translate: (options) ->
    if options.id
      query = options.id

    else if options.namespace and options.key
      query = _.pick options, 'namespace', 'key'

    else
      throw new AE.ArgumentNullException "Id or namespace-key pair was not provided."

    translationDocument = AB.Translation.documents.findOne query

    return "" unless translationDocument

    translation = translationDocument.translate options.language
    translation.text

  # Returns translation data for a specific language.
  translation: (language = Artificial.Babel.defaultLanguage) ->
    languageProperty = language.toLowerCase().replace '-', '.'
    _.nestedProperty translations, languageProperty

  # Finds the best translation in order of preferred languages.
  translate: (languagePreference = AB.userLanguagePreference()) ->
    # Start with an empty array if there is no language preference.
    languagePreference ?= []

    # Go over preferred languages and resort to default language otherwise.
    languages = _.map languagePreference, _.toLower
    languages = _.union languages, [AB.defaultLanguage.toLowerCase()]

    for language in languages
      languageParts = language.split '-'

      translation = @_findTranslation @translations, languageParts
      return translation if translation

    # We've looked through all the languages and couldn't find a translation, so return just the key.
    text: @key
    language: null

  _findTranslation: (data, languageParts, currentPath = '') ->
    # Return if we didn't find the object for that language part.
    return unless data

    # Search for the best translation when we come to the end of language parts.
    unless languageParts.length
      # There are no more language parts to narrow our scope, so
      # search for all the translations across all the nested objects.
      translations = @_findTranslations data, currentPath
      return unless translations.length

      # We have at least one translation, so find one with the highest quality.
      best = _.last _.sortBy translations, (data) ->
        data.translation.quality

      # Return the translation text with a language descriptor.
      text: best.translation.text
      language: best.path

    else
      # Try to find translations deeper.
      newPath = if currentPath.length then "#{currentPath}-#{languageParts[0]}" else languageParts[0]

      @_findTranslation data[languageParts[0]], _.tail(languageParts), newPath

  _findTranslations: (data, currentPath) ->
    # Return just this object in an array if it has the translated text.
    return [
      translation: data
      path: currentPath
    ] if data.text

    # Search for the objects in all the properties and make one array of all their results.
    _.flatten _.map data, (value, key) =>
      if _.isObject value
        newPath = if currentPath.length then "#{currentPath}-#{key}" else key
        @_findTranslations value, newPath

      else
        []

AB.Translation = ArtificialBabelTranslation
