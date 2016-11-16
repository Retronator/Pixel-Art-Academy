AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

class HQ.Locations.Store.Shelf extends LOI.Adventure.Item
  template: -> 'Retronator.HQ.Locations.Store.Shelf'
    
  constructor: ->
    super
    
    @addAbilityLook()

  onCreated: ->
    super

    # Get all store items data.
    @subscribe RS.Transactions.Item.all

    # Get all user's transactions and payments so we can determine which store items they are
    # eligible for. Payments are needed to determine if the user has a kickstarter pledge.
    @subscribe RS.Transactions.Transaction.forCurrentUser
    @subscribe RS.Transactions.Payment.forCurrentUser

  shoppingCart: ->
    RS.shoppingCart

  storeItems: ->
    items = RS.Transactions.Item.documents.find
      price:
        $exists: true
    ,
      sort:
        price: 1

    # Show only items that the user is eligible to purchase.
    items = _.filter items.fetch(), (item) =>
      # We need to perform validation with inherited child's code, so first do a cast.
      item = item.cast()

      try
        item.validateEligibility()

      catch error
        return false

      true

    # Refresh all the items to populate bundle sub-items.
    item.refresh() for item in items

    items

  events: ->
    super.concat
      'click .add-to-cart-button': @onClickAddToCartButton

  onClickAddToCartButton: (event) ->
    item = @currentData()

    # Add the item's ID to the shopping cart state.
    store = @options.adventure.gameState().locations[HQ.Locations.Store.id()]
    shoppingCart = store.things[HQ.Locations.Store.ShoppingCart.id()] ?= {}
    shoppingCart.contents ?= []

    shoppingCart.contents.push
      item: item.catalogKey
      isGift: false

    @options.adventure.gameState.updated()

    LOI.Adventure.goToItem HQ.Locations.Store.ShoppingCart
