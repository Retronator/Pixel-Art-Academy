AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

Vocabulary = LOI.Parser.Vocabulary

class HQ.Store.Shelf extends LOI.Adventure.Item
  template: -> 'Retronator.HQ.Store.Shelf'

  constructor: ->
    super

  onCreated: ->
    super

    # Get all store items data.
    @_itemsSubscription = @subscribe RS.Transactions.Item.all

    # Get all user's transactions and payments so we can determine which store items they are
    # eligible for. Payments are needed to determine if the user has a kickstarter pledge.
    @subscribe RS.Transactions.Transaction.forCurrentUser
    @subscribe RS.Transactions.Payment.forCurrentUser

  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      # HACK: Deactivate item on adventure first to prevent a render component error. TODO: Figure out why.
      LOI.adventure.deactivateCurrentItem()
      finishedDeactivatingCallback()
    ,
      500

  shoppingCart: ->
    RS.shoppingCart

  catalogKeys: -> [] # Override with specific shelf items.

  storeItems: ->
    return unless @_itemsSubscription.ready()

    items = RS.Transactions.Item.documents.find
      price:
        $exists: true
    ,
      sort:
        price: 1

    # Show only items that are supposed to be on this shelf.
    items = _.filter items.fetch(), (item) =>
      item.catalogKey in @catalogKeys()

    # Cast the items to enable any extra functionality.
    items = for item in items
      item.cast()

    # Refresh all the items to populate bundle sub-items.
    item.refresh() for item in items

    console.log "Shelf displaying items", items if HQ.debug

    items

  canBuy: ->
    item = @currentData()

    # We need to perform validation with inherited child's code, so first do a cast.
    item = item.cast()

    try
      item.validateEligibility()

    catch error
      return false

    true

  canBuyClass: ->
    'can-buy' if @canBuy()

  events: ->
    super.concat
      'click .add-to-cart-button': @onClickAddToCartButton

  onClickAddToCartButton: (event) ->
    item = @currentData()
        
    # Add the Shopping Cart app to the tablet.
    tablet = @playerTablet()
    tablet.addApp HQ.Items.Tablet.Apps.ShoppingCart, (shoppingCart) =>

      # Add the item's ID to the shopping cart state.
      shoppingCartState = shoppingCart.state()
      shoppingCartState.contents ?= []

      shoppingCartState.contents.push
        item: item.catalogKey
        isGift: false

      # Switch the tablet app to Shopping Cart.
      tablet.os.state().activeAppId = HQ.Items.Tablet.Apps.ShoppingCart.id()

      LOI.adventure.gameState.updated()

      # Activate the tablet into overlaid mode
      tablet.activate()

  # Listener

  onCommand: (commandResponse) ->
    shelf = @options.parent

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.Use], shelf.avatar]
      priority: 1
      action: =>
        LOI.adventure.goToItem shelf
