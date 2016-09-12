AE = Artificial.Everywhere
RA = Retronator.Accounts

class RA.Transactions.ShoppingCart

  @ShoppingCartItemsLocalStorageKey: "Retronator.Accounts.Transactions.ShoppingCart.items"

  constructor: (options) ->
    @_cartItems = options?.items ? []
    @supporterName = new ReactiveField options?.supporterName ? null
    @tipAmount = new ReactiveField options?.tip?.amount ? 0
    @tipMessage = new ReactiveField options?.tip?.message ? null

    @_itemsDependency = new Tracker.Dependency

    # On the client, try to load the items from local storage.
    if Meteor.isClient and not @_cartItems.length
      storedItems = localStorage.getItem @constructor.ShoppingCartItemsLocalStorageKey
      @_cartItems = EJSON.parse storedItems if storedItems

    # Recreate items from the database. They might not yet be loaded from the database, so run it reactively.
    Tracker.autorun (computation) =>
      itemsRecreated = 0

      for cartItem in @_cartItems
        # Find the item document.
        item = RA.Transactions.Item.documents.findOne cartItem.item._id
        continue unless item

        cartItem.item = item.cast()
        itemsRecreated++

      # Stop when all the items were successfully recreated.
      return unless itemsRecreated is @_cartItems.length

      computation.stop()

      # Also refresh all sub-items. We're assuming that by now all the items have been transferred from the database.
      @refreshItemDocuments()

      @_itemsDependency.changed()

  toDataObject: ->
    items = for cartItem in @_cartItems
      item:
        _id: cartItem.item._id
      isGift: cartItem.isGift

    items: items
    supporterName: @supporterName()
    tip:
      amount: @tipAmount()
      message: @tipMessage()

  @fromDataObject: (data) ->
    new @ data

  items: ->
    # Register a dependency on array changes.
    @_itemsDependency.depend()

    # Return a shallow copy so that our internal array can't be compromised.
    item for item in @_cartItems

  totalPrice: ->
    # Register a dependency on array changes.
    @_itemsDependency.depend()

    # The total price is the sum of the items plus the tip.
    itemsCost = @tipAmount()
    itemsCost += cartItem.item.price for cartItem in @_cartItems

    itemsCost

  addItem: (item, isGift = false) ->
    # Add the item and make sure it is of its correct inherited type.
    @_cartItems.push
      item: item.cast()
      isGift: isGift

    @_onShoppingCartUpdated()

  setItem: (index, item) ->
    @_cartItems[index] = item
    @_onShoppingCartUpdated()
    
  setItemIsGift: (item, isGift) ->
    item.isGift = isGift
    @_onShoppingCartUpdated()

  removeItem: (item) ->
    index = @_cartItems.indexOf item
    @removeItemAtIndex index

  removeItemAtIndex: (index) ->
    return unless index > -1

    @_cartItems.splice index, 1
    @_onShoppingCartUpdated()

  removeAllItems: ->
    @_cartItems = []
    @_onShoppingCartUpdated()

  reset: ->
    @removeAllItems()
    @supporterName null
    @tipAmount 0
    @tipMessage null

  refreshItemDocuments: ->
    for cartItem in @_cartItems
      cartItem.item.refresh()

    @_onShoppingCartUpdated()

  validate: ->
    # Make sure the user can purchase all the items in the shopping cart.
    cartItem.item.validateEligibility() for cartItem in @_cartItems

    # Make sure all the items marked as gifts are giftable.
    for cartItem in @_cartItems
      throw new AE.ArgumentException "#{cartItem.item.debugName()} can't be purchased as a gift." if cartItem.isGift and not cartItem.item.isGiftable
    
  _onShoppingCartUpdated: ->
    # On the client, store the shopping cart into local storage.
    if Meteor.isClient
      # Store only item ids.
      items = for cartItem in @_cartItems
        item:
          _id: cartItem.item._id
        isGift: cartItem.isGift

      encodedItemIds = EJSON.stringify items
      localStorage.setItem @constructor.ShoppingCartItemsLocalStorageKey, encodedItemIds

    @_itemsDependency.changed()

Match.ShoppingCart = Match.ObjectIncluding
  items: [
    item: Match.ObjectIncluding
      _id: Match.DocumentId
    isGift: Boolean
  ]
  supporterName: Match.OptionalOrNull String
  tip:
    amount: Match.Where (value) ->
      check value, Number
      value >= 0
    message: Match.OptionalOrNull String
