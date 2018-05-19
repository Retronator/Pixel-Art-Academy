LOI = LandsOfIllusions

cache = null

cachableDocumentsQuery =
  authors:
    $exists: false

Meteor.startup ->
  Tracker.autorun ->
    # Invalidate cache on sprite changes.
    LOI.Assets.Sprite.documents.find(cachableDocumentsQuery).observeChanges
      added: -> cache = null
      changed: -> cache = null
      removed: -> cache = null

WebApp.connectHandlers.use LOI.Assets.Sprite.cacheUrl, (request, response, next) ->
  unless cache
    cache = {}

    sprites = LOI.Assets.Sprite.documents.fetch cachableDocumentsQuery

    for sprite in sprites
      cache[sprite._id] = sprite

    cache = JSON.stringify cache

  response.writeHead 200, 'Content-Type': 'application/json'
  response.write cache
  response.end()
