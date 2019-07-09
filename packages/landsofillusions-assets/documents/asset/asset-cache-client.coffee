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

        # Convert plain objects into assets.
        cache = {}

        for id, asset of assets
          cache[id] = new LOI.Assets[@className] asset

        @_cache cache

  @cacheReady: ->
    @_cache()?

  @getFromCache: (id) ->
    @_cache()?[id]
    
  @findInCache: (matcherOrFunction) ->
    return unless cache = @_cache()

    if _.isFunction matcherOrFunction
      for assetId, asset of cache
        return asset if matcherOrFunction asset

    else if _.isObject matcherOrFunction
      for assetId, asset of cache
        found = true

        for key, value of matcherOrFunction
          unless asset[key] is value
            found = false
            break

        return asset if found

    null

  @findAllInCache: (matcherOrFunction) ->
    assets = []
    return assets unless cache = @_cache()

    if _.isFunction matcherOrFunction
      for assetId, asset of cache
        assets.push asset if matcherOrFunction asset

    else if _.isObject matcherOrFunction
      for assetId, asset of cache
        found = true

        for key, value of matcherOrFunction
          unless asset[key] is value
            found = false
            break

        assets.push asset if found

    assets
