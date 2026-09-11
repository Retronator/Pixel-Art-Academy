AB = Artificial.Base
PAA = PixelArtAcademy

class PAA.Pico8.Cartridges.Snake.Project.AssetsProvider extends PAA.Practice.Project.AssetsProvider
  constructor: ->
    super arguments...

    @_assets = Tracker.nonreactive => [
      new PAA.Pico8.Cartridges.Snake.Food @
      new PAA.Pico8.Cartridges.Snake.Body @
    ]
    
  destroy: ->
    asset.destroy() for asset in @_assets

  assets: -> @_assets
