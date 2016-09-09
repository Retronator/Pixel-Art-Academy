AB = Artificial.Babel
AT = Artificial.Telepathy

class AB.Translation extends AT.RemoteDocument
  # namespace: string name of related keys
  # key: English string that identifies this translation (namespace and key pair should be unique)
  # translations:
  #   {language}: two-character language code
  #     {region}: two-character region code
  #       text: translated text of the key
  #       quality: a number by which we can sort translations from different regions to find the best translation
  #       meta: TODO: information about the translation process, authors, revisions, voting etc.
  @Meta
    # Make an abstract class, because we don't want to create a collection on the
    # client. It will be instead created from the server using the remote connection.
    abstract: true

  translation: (language) ->
    languageProperty = language.replace '-', '.'
    _.nestedProperty translations, languageProperty

  translate: (languagePreference) ->
    for language in languagePreference
      languageParts = language.split '-'

      translation = @_findTranslation @translations, languageParts
      return translation if translation

    # We've looked through all the preferred languages and couldn't find a translation, so return just the key.
    text: @key
    language: null

  _findTranslation: (data, languageParts, currentPath = '') ->
    # Return if we didn't find the object for that language part.
    return unless data

    # Search for the best translation when we come to the end of language parts.
    if languageParts.length is 0
      # There are no more language parts to narrow our scope, so
      # search for all the translations across all the nested objects.
      translations = @_findTranslations data, currentPath
      return unless translations.length

      # We have at least one translation, but find one with the highest quality.
      best = _.last _.sortBy translations, (data) ->
        data.translation.quality

      # Return the translation text with a language descriptor.
      text: best.translation.text
      language: best.path

    else
      # Try to find translations deeper.
      newPath = if currentPath.length then "#{currentPath}-#{languageParts[0]}" else languageParts[0]

      @_findTranslation data[languageParts[0]], _.rest(languageParts), newPath

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

# On the server, also create an actual collection. On the clients, the
# collection will be created together with the instance of the Babel Server.
if Meteor.isServer
  class ArtificialBabelTranslation extends AB.Translation
    @Meta
      name: 'ArtificialBabelTranslation'

  AB.Translation = ArtificialBabelTranslation
