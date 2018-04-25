AM = Artificial.Mummification
LOI = LandsOfIllusions

# A 2D image asset.
class LOI.Assets.Sprite extends LOI.Assets.Sprite
  @Meta
    name: @id()
    replaceParent: true

  # Load cache.
  @_cache = new ReactiveField null

  HTTP.get @cacheUrl, (error, response) =>
    sprites = JSON.parse response.content

    # Convert plain objects into sprites.
    cache = {}

    for id, sprite of sprites
      cache[id] = new LOI.Assets.Sprite sprite

    @_cache cache

  @getFromCache: (id) ->
    @_cache()?[id]
