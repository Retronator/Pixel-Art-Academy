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
    if tablet = @options.adventure.inventory HQ.Items.Tablet
      if shoppingCart = tablet.apps HQ.Items.Tablet.Apps.ShoppingCart
        # If receipt is showing, use receipts' top transactions.
        if shoppingCart.state().receiptVisible
          return shoppingCart.receipt.topRecentTransactions()

    # We couldn't get to receipt's modified transactions so just show the unmodified ones.
    RS.Components.TopSupporters.topRecentTransactions.find {},
      sort: [
        ['amount', 'desc']
        ['time', 'desc']
      ]
