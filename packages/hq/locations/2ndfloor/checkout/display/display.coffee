AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

class HQ.Locations.Checkout.Display extends LOI.Adventure.Item
  @id: -> 'Retronator.HQ.Locations.Checkout.Display'
  @url: -> 'retronator/checkout/display'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "supporters display"

  @shortName: -> "display"

  @description: ->
    "
      It's a big screen showing a list of people and their contributions.
    "

  @initialize()

  constructor: ->
    super

    @addAbilityToActivateByLooking()

  onCreated: ->
    super

    @subscribe RS.Transactions.Transaction.topRecent

  topRecentTransactions: ->
    # Get top recent transactions from the shopping cart receipt component.
    RS.Components.TopSupporters.topRecentTransactions.find {},
      sort: [
        ['amount', 'desc']
        ['time', 'desc']
      ]
