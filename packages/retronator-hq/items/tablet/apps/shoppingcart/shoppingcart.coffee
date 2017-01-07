AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

class HQ.Items.Tablet.Apps.ShoppingCart extends HQ.Items.Tablet.OS.App
  # STATE
  # contents: list of cart items
  #   item: store item object
  #   cartIndex: where to appear in the shopping cart
  #   isGift: boolean if this item will be a gift
  # showSupporterName: should the transaction show the supporter name or be anonymous (only applies to logged out user)
  # supporterName: the name that will appear with the transaction (only applies to logged out user)
  # tip:
  #   amount: how much extra you're paying to support the game
  #   message: the message that you can add with the tip
  # receiptVisible: is the app showing the receipt
  @id: -> 'Retronator.HQ.Items.Tablet.Apps.ShoppingCart'
  @url: -> 'shoppingcart'

  @register @id()

  @fullName: -> "Shopping Cart"

  @description: ->
    "
      It's a shopping cart that holds the items you want to buy.
    "

  @initialize()

  constructor: (@options) ->
    super

    @receipt = new HQ.Items.Tablet.Apps.ShoppingCart.Receipt
      shoppingCart: @
      adventure: @options.adventure

    @contents = @stateObject.field 'contents', default: []

    @receiptVisible = @stateObject.field 'receiptVisible'
      
  onCreated: ->
    super

    # Get all store items data.
    @subscribe RS.Transactions.Item.all

  showHomeScreenButton: ->
    not @receiptVisible()

  cartItems: ->
    items = for cartItem, i in @contents()
      item = RS.Transactions.Item.documents.findOne catalogKey: cartItem.item
      break unless item

      # Load bundle items as well.
      for bundleItem in item.items
        bundleItem.refresh()

      item: item
      isGift: cartItem.isGift
      cartIndex: i

    items

  giftCheckboxAttributes: ->
    item = @currentData()

    checked: true if item.isGift

  totalPrice: ->
    # The total price is the sum of the items.
    _.sum (storeItem.item.price for storeItem in @cartItems())

  receiptVisibleClass: ->
    'receipt-visible' if @receiptVisible()
    
  events: ->
    super.concat
      'click .remove-from-cart-button': @onClickRemoveFromCartButton
      'change .gift-checkbox': @onChangeGiftCheckbox

  onClickRemoveFromCartButton: (event) ->
    item = @currentData()

    # Remove the item's ID from the shopping cart contents.
    contents = @contents()
    contents.splice item.cartIndex, 1
    @contents contents

  onChangeGiftCheckbox: (event) ->
    item = @currentData()

    RS.shoppingCart.setItemIsGift item, event.target.checked
