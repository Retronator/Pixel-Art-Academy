AB = Artificial.Babel

cache = null

WebApp.connectHandlers.use AB.cacheUrl, (request, response, next) ->
  unless cache
    # Get all translations with a namespace and a key.
    translations = AB.Translation.documents.fetch
      namespace: $exists: true
      key: $exists: true

    cache = {}

    for translation in translations
      cache[translation.namespace] ?= {}
      cache[translation.namespace][translation.key] = [translation._id, translation.translations]

    cache = JSON.stringify cache

  response.writeHead 200, 'Content-Type': 'application/json'
  response.write cache
  response.end()
