AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

class HQ.Store.Shelf.Patreon extends HQ.Store.Shelf
  @id: -> 'Retronator.HQ.Store.Shelf.Patreon'
  @url: -> 'retronator/store/patreon'

  @register @id()

  @version: -> '0.0.1'

  @fullName: -> "Patreon store ![shelf](look at shelf)"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name

  @description: ->
    "
      This shelf holds game bundles of Pixel Art Academy you can redeem with a Patreon subscription.
    "

  @initialize()

  # Show the Patreon shelf since it'll be the only one for a while.
  isVisible: -> true

  catalogKeys: ->
    [
      RS.Items.CatalogKeys.Retronator.Patreon.Subscriptions
      RS.Items.CatalogKeys.Bundles.PixelArtAcademy.PreOrder.BasicGame
      RS.Items.CatalogKeys.Bundles.PixelArtAcademy.PreOrder.FullGame
      RS.Items.CatalogKeys.Bundles.PixelArtAcademy.PreOrder.AlphaAccess
      RS.Items.CatalogKeys.Bundles.PixelArtAcademy.PreOrder.AvatarEditorUpgrade
      RS.Items.CatalogKeys.Bundles.PixelArtAcademy.PreOrder.AlphaAccessUpgrade
    ]

  canBuyFromShelf: -> not LOI.characterId()
