AE = Artificial.Everywhere
AB = Artificial.Babel
AT = Artificial.Telepathy
AM = Artificial.Mummification

# Document that stores the translated texts for a given key in a namespace.
class AB.Translation extends AM.Document
  @id: -> 'Artificial.Babel.Translation'
  # namespace: string name of related keys
  # key: English string that identifies this translation (namespace and key pair should be unique)
  # ownerId: when the translation is a user supplied string, this field allows that user who created it to change translations
  # translations:
  #   text: language-agnostic text of the key
  #   quality: a number by which we can sort translations from different languages to find the best translation
  #   meta: TODO: information about the translation process, authors, revisions, voting etc.
  #   best: computed best translation from all the translations
  #     text: text of the best translation
  #     quality: quality of the best translation
  #     languageRegion: which language-region this translation comes from
  #   {language}: two-character language code
  #     text: translated text of the key for this specific language (but region-agnostic)
  #     quality
  #     meta
  #     best: computed best translation for this language and regions
  #       text
  #       quality
  #       languageRegion
  #     {region}: two-character region code
  #       text: translated text of the key for this specific region of the language
  #       quality
  #       meta
  @Meta
    name: @id()

  @insert: @method 'insert'
  @update: @method 'update'
  @remove: @method 'remove'
  @moveLanguage: @method 'moveLanguage'
  @removeLanguage: @method 'removeLanguage'

  @forId: @subscription 'forId'
  @forNamespace: @subscription 'forNamespace'

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
  translationData: (languageRegion) ->
    if languageRegion?.length
      languageProperty = languageRegion.toLowerCase().replace '-', '.'
      _.nestedProperty @translations, languageProperty

    else
      # Return the global translation.
      @translations

  # Returns an array with all translation data available.
  allTranslationData: ->
    translations = []

    # See if there is a global translation.
    @_addTranslation translations, @translations

    for languageCode, languageData of @translations when languageCode.length is 2
      # See if there is a translation on the language itself.
      @_addTranslation translations, languageData, languageCode

      # Go through all regions as well.
      for regionCode, translationData of languageData when regionCode.length is 2
        @_addTranslation translations, translationData, languageCode, regionCode

    translations

  _addTranslation: (translations, translationData, languageCode, regionCode) ->
    # Translation is present if it holds a text field.
    return unless translationData.text?

    languageRegion = _.joinLanguageRegion languageCode, regionCode

    translations.push {languageRegion, translationData}

  # Finds the best translation in order of preferred languages.
  translate: (languagePreference = AB.userLanguagePreference()) ->
    for languageRegion in languagePreference
      translation = @_findTranslation languageRegion
      return translation if translation

    # We couldn't find any of user's specific wishes. Let's try again with languages of regions.
    for languageRegion in languagePreference
      {languageCode, regionCode} = _.splitLanguageRegion languageRegion

      # Only process the ones with regions, but translate as if the user requested that language (without region).
      if regionCode
        translation = @_findTranslation languageCode
        return translation if translation

    # Finally, just return the best translation.
    if @translations?.best?
      text: @translations.best.text
      language: @translations.best.languageRegion

    else
      # Not even the best translation is available (we have no translations at all), so return just the key.
      text: @key
      language: null

  _findTranslation: (languageRegion) ->
    {languageCode, regionCode} = _.splitLanguageRegion languageRegion

    if regionCode
      # If the user cares about the region, look for that region's entry directly.
      translationData = @translationData languageRegion

      return unless translationData

      text: translationData.text
      language: _.joinLanguageRegion languageCode, regionCode

    else if languageCode
      # Otherwise the user just cares about the best translation in the given language
      translationData = @translationData languageCode

      return unless translationData

      text: translationData.best.text
      language: translationData.best.languageRegion

    else
      null

  # Populates the translations with the best translations.
  generateBestTranslations: ->
    return unless @translations

    @_generateBestTranslations @translations, ''

  _generateBestTranslations: (node, languageRegion) ->
    # Set the best to local translation if it's there.
    best =
      text: node.text
      quality: node.quality ? -1
      languageRegion: languageRegion

    # Go through all the node keys.
    for key, childNode of node
      # If the key is 2 characters long it is a language or region, so dig deeper.
      if key.length is 2
        if languageRegion.length
          # We're in a language node, so the node here is a region. Compare its quality directly.
          regionNode = childNode

          if regionNode.quality > best.quality
            best.text = regionNode.text
            best.quality = regionNode.quality
            best.languageRegion = "#{languageRegion}-#{key.toUpperCase()}"

        else
          # We're at the top node, so compute the best translation for the whole language node first.
          language = key.toLowerCase()
          languageNode = childNode
          @_generateBestTranslations languageNode, language

          # Now compare our best with their best.
          if languageNode.best.quality > best.quality
            best.text = languageNode.best.text
            best.quality = languageNode.best.quality
            best.languageRegion = languageNode.best.languageRegion

    node.best = best
