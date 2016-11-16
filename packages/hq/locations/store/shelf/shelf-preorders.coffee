AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

class HQ.Locations.Store.Shelf.PreOrders extends HQ.Locations.Store.Shelf
  @id: -> 'Retronator.HQ.Locations.Store.Shelf.PreOrders'
  @url: -> 'retronator/lobby/store/preorders'

  @register @id()

  @fullName: -> "pre-orders shelf"

  @shortName: -> "pre-orders"

  @description: ->
    "
      This shelf holds all pre-order bundles of Pixel Art Academy.
    "

  @initialize()
