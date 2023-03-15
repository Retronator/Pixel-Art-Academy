AB = Artificial.Babel

Meteor.startup ->
  Artificial.Mummification.DocumentCaches.add AB.cacheUrl, ->
    # Get all translations with a namespace and a key.
    translations = AB.Translation.documents.fetch
      namespace: $exists: true
      key: $exists: true

    cache = {}

    for translation in translations
      cache[translation.namespace] ?= {}
      cache[translation.namespace][translation.key] = [translation._id, translation.translations]

    cache
