AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

class HQ.Locations.Store.ShoppingCart extends LOI.Adventure.Item
  @id: -> 'Retronator.HQ.Locations.Store.ShoppingCart'
  @url: -> 'retronator/store/cart'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "shopping cart"

  @shortName: -> "cart"

  @description: ->
    "
      It's a shopping cart that holds the items you want to buy.
    "

  @initialize()

  constructor: (@options) ->
    super
    
    @addAbilityLook()

    # Get all store items data.
    @subscribe RS.Transactions.Item.all

  storeItems: ->
    items = for cartItem in @state().contents
      item = RS.Transactions.Item.documents.findOne catalogKey: cartItem.item
      break unless item

      # Load bundle items as well.
      for bundleItem in item.items
        bundleItem.refresh()

      item: item
      isGift: cartItem.isGift

    items

  giftCheckboxAttributes: ->
    item = @currentData()

    checked: true if item.isGift

  totalPrice: ->
    # The total price is the sum of the items plus the tip.
    _.sum (storeItem.item.price for storeItem in @storeItems())

  events: ->
    super.concat
      'click .remove-from-cart-button': @onClickRemoveFromCartButton
      'change .gift-checkbox': @onChangeGiftCheckbox

  onClickRemoveFromCartButton: (event) ->
    item = @currentData()

    RS.shoppingCart.removeItem item

  onChangeGiftCheckbox: (event) ->
    item = @currentData()

    RS.shoppingCart.setItemIsGift item, event.target.checked
