AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

class HQ.Store.Shelf.Game extends HQ.Store.Shelf
  @id: -> 'Retronator.HQ.Store.Shelf.Game'
  @url: -> 'retronator/store/game'

  @register @id()

  @version: -> '0.0.1'

  @fullName: -> "Game shelf"

  @shortName: -> "game"

  @description: ->
    "
      This shelf holds pre-order game bundles of Pixel Art Academy.
    "

  @initialize()

  catalogKeys: ->
    [
      RS.Items.CatalogKeys.Bundles.PixelArtAcademy.PreOrder.BasicGame
      RS.Items.CatalogKeys.Bundles.PixelArtAcademy.PreOrder.FullGame
      RS.Items.CatalogKeys.Bundles.PixelArtAcademy.PreOrder.AlphaAccess
    ]
