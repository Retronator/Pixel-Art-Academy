AE = Artificial.Everywhere
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

class LOI.Assets.Asset extends AM.Document
  @Meta: (meta) ->
    super arguments...
    
    return if meta.abstract
  
    # Load cache.
    @_cache = new ReactiveField null

    Meteor.startup =>
      HTTP.get @cacheUrl(), (error, response) =>
        assets = JSON.parse response.content

        # Convert plain objects into sprites.
        cache = {}

        for id, asset of assets
          cache[id] = new LOI.Assets[@className] asset

        @_cache cache

  @getFromCache: (id) ->
    @_cache()?[id]
