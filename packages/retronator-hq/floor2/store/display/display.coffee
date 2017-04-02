AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

Vocabulary = LOI.Parser.Vocabulary

class HQ.Store.Display extends LOI.Adventure.Item
  @id: -> 'Retronator.HQ.Store.Display'
  @url: -> 'retronator/store/display'

  @register @id()
  template: -> @constructor.id()

  @version: -> '0.0.1'

  @fullName: -> "supporters display"
  @shortName: -> "display"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name

  @description: ->
    "
      It's a big screen showing a list of people and their contributions.
    "

  @initialize()

  # Listener

  onCommand: (commandResponse) ->
    display = @options.parent

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.Use], display.avatar]
      priority: 1
      action: =>
        LOI.adventure.goToItem display

  # Component

  onCreated: ->
    super

    @subscribe RS.Transactions.Transaction.topRecent

  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      # HACK: Deactivate item on adventure first to prevent a render component error. TODO: Figure out why.
      LOI.adventure.deactivateCurrentItem()
      finishedDeactivatingCallback()
    ,
      500
    
  topRecentTransactions: ->
    # Get top recent transactions from the shopping cart receipt component.
    if false and tablet = LOI.adventure.inventory HQ.Items.Tablet
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
