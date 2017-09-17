AB = Artificial.Babel

AB.Translation.forNamespace.publish (namespace, keyOrKeys, languages) ->
  check namespace, String
  check keyOrKeys, Match.OptionalOrNull Match.OneOf String, [String]
  check languages, Match.OptionalOrNull [String]

  # Search through the namespace and all sub-namespaces.
  query =
    namespace: new RegExp('^' + namespace)

  query.key = keyOrKeys if _.isString keyOrKeys
  query.key = $in: keyOrKeys if _.isArray keyOrKeys

  AB.Translation.documents.find query,
    fields: generateFieldsForLanguages languages

AB.Translation.forId.publish (translationId, languages) ->
  check translationId, Match.DocumentId
  check languages, Match.OptionalOrNull [String]

  AB.Translation.documents.find
    _id: translationId
  ,
    fields: generateFieldsForLanguages languages

generateFieldsForLanguages = (languages) ->
  fields =
    namespace: 1
    key: 1

  if languages?
    # Make all languages lowercase.
    languages = _.map languages, _.toLower

    minimalLanguages = []

    # Construct the minimal required language set by removing subsets (for example 'en' already includes 'en-US').
    for language in languages
      redundant = false

      # Compare to all the other languages.
      for otherLanguage in _.without languages, language
        # If this language is contained within the other language, we don't need it.
        redundant = true if _.startsWith language, otherLanguage

      minimalLanguages.push language unless redundant

    for language in minimalLanguages
      # Change language dash into subdocument notation.
      field = "translations.#{language.toLowerCase().replace '-', '.'}"
      fields[field] = 1

    # Subscribe to all region languages' bests.
    for language in _.filter(minimalLanguages, (language) => language.length is 5)
      {languageCode} = _.splitLanguageRegion language
      field = "translations.#{languageCode.toLowerCase()}.best"
      fields[field] = 1

    # Finally the overall best.
    fields['translations.best'] = 1

  else
    # Include all languages.
    fields.translations = 1

  fields
