AE = Artificial.Everywhere
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

class LOI.Assets.Asset extends AM.Document
  @Meta: (meta) ->
    super

    return if meta.abstract

    cache = null
    
    cachableDocumentsQuery =
      authors:
        $exists: false
    
    Meteor.startup =>
      Tracker.autorun =>
        # Invalidate cache on document changes.
        LOI.Assets[@className].documents.find(cachableDocumentsQuery).observeChanges
          added: -> cache = null
          changed: -> cache = null
          removed: -> cache = null

      WebApp.connectHandlers.use @cacheUrl(), (request, response, next) =>
        unless cache
          # Rebuild cache.
          cache = {}

          assets = LOI.Assets[@className].documents.fetch cachableDocumentsQuery,
            # Do not send history in cache.
            fields:
              history: false
              historyPosition: false

          for asset in assets
            cache[asset._id] = asset

          cache = JSON.stringify cache

        response.writeHead 200, 'Content-Type': 'application/json'
        response.write cache
        response.end()
