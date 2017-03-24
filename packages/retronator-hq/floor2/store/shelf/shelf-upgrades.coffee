AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

class HQ.Store.Shelf.Upgrades extends HQ.Store.Shelf
  @id: -> 'Retronator.HQ.Store.Shelf.Upgrades'
  @url: -> 'retronator/store/upgrades'

  @register @id()

  @version: -> '0.0.1'

  @fullName: -> "upgrades shelf"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name

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
