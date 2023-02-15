AB = Artificial.Babel

cache = null

Meteor.startup ->
  Tracker.autorun ->
    # Invalidate cache on translation changes.
    AB.Translation.documents.find(
      namespace: $exists: true
      key: $exists: true
    ).observeChanges
      added: -> cache = null
      changed: -> cache = null
      removed: -> cache = null

WebApp.connectHandlers.use AB.cacheUrl, (request, response, next) ->
  unless cache
    console.log "Recomputing Artificial Babel Translations cache." if Artificial.debug
    # Get all translations with a namespace and a key.
    translations = AB.Translation.documents.fetch
      namespace: $exists: true
      key: $exists: true

    cache = {}

    for translation in translations
      cache[translation.namespace] ?= {}
      cache[translation.namespace][translation.key] = [translation._id, translation.translations]

    cache = JSON.stringify cache

  response.writeHead 200,
    'Content-Type': 'application/json'
    'Access-Control-Allow-Origin': '*'

  response.write cache
  response.end()
