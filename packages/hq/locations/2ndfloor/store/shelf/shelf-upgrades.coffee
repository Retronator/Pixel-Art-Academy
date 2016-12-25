AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

class HQ.Locations.Store.Shelf.Upgrades extends HQ.Locations.Store.Shelf
  @id: -> 'Retronator.HQ.Locations.Store.Shelf.Upgrades'
  @url: -> 'retronator/store/upgrades'

  @register @id()

  @version: -> '0.0.1'

  @fullName: -> "Upgrades shelf"

  @shortName: -> "upgrades"

  @description: ->
    "
      This shelf holds pre-order upgrade bundles of Pixel Art Academy.
    "

  @initialize()

  catalogKeys: ->
    [
      RS.Items.CatalogKeys.Bundles.PixelArtAcademy.PreOrder.AvatarEditorUpgrade
      RS.Items.CatalogKeys.Bundles.PixelArtAcademy.PreOrder.AlphaAccessUpgrade
    ]
