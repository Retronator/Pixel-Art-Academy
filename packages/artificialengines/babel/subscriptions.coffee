AB = Artificial.Babel

Meteor.publish 'Artificial.Babel.translations', (namespace, keys, languages) ->
  check namespace, String
  check keys, Match.Any
  check languages, Match.OptionalOrNull [String]

  query =
    namespace: namespace

  query.key = keys if keys

  fields =
    namespace: 1
    key: 1

  if languages?.length
    # Construct the minimal required language set by removing subsets (for example 'en' already includes 'en-US').
    for language in languages
      # Compare to at all the other languages.
      for otherLanguage in _.without languages, language
        # If the other language is contained within the language, we don't need it.
        languages = _.without languages, otherLanguage if _.startsWith otherLanguage, language

    for language in languages
      # Change language dash into subdocument notation.
      field = "translations.#{language.replace '-', '.'}"
      fields[field] = 1

  else
    # Include all languages.
    fields.translations = 1

  AB.Translation.documents.find query,
    fields: fields
