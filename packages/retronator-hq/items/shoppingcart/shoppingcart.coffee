LOI = LandsOfIllusions
HQ = Retronator.HQ
RS = Retronator.Store

Vocabulary = LOI.Parser.Vocabulary

class HQ.Items.ShoppingCart extends LOI.Adventure.Item
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
  @id: -> 'Retronator.HQ.Items.ShoppingCart'
  @url: -> 'retronator/store/shopping-cart'
  @register @id()
  template: -> @id()

  @version: -> '0.0.1'

  @fullName: -> "shopping cart"
  @shortName: -> "cart"
  @descriptiveName: -> "Shopping ![cart](look in cart)."
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name

  @description: ->
    "
      It's a shopping cart you can use to buy things in the store.
    "

  @initialize()

  @defaultScriptUrl: -> 'retronator_retronator-hq/items/shoppingcart/shoppingcart.script'

  @addItem: (catalogKey) ->
    # Add the item's ID to the shopping cart state.
    contents = @state('contents') or []

    contents.push
      item: catalogKey
      isGift: false

    @state 'contents', contents

  @clearItems: ->
    @state 'contents', []

  constructor: (@options) ->
    super arguments...

    @contents = @state.field 'contents', default: []

  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500

  giftCheckboxAttributes: ->
    item = @currentData()

    checked: true if item.isGift

  totalPrice: ->
    # The total price is the sum of the items.
    _.sum (storeItem.item.price for storeItem in @cartItems())
    
  isVisible: ->
    # Show the shopping cart unless it's in the process of checkout.
    not @state 'atCheckout'

  events: ->
    super(arguments...).concat
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

  # Script

  initializeScript: ->
    @setCallbacks
      LeaveWithCart: (complete) =>
        complete()

        # Drop the cart.
        HQ.Items.ShoppingCart.state 'inInventory', false

        # Move the user outside.
        LOI.adventure.goToLocation SanFrancisco.Soma.SecondStreet

  # Listener

  onCommand: (commandResponse) ->
    shoppingCart = @options.parent

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.Get], shoppingCart.avatar]
      action: =>
        if shoppingCart.state 'inInventory'
          @startScript label: 'AlreadyInInventory'
          return

        shoppingCart.state 'inInventory', true

        true

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.LookIn, Vocabulary.Keys.Verbs.Use, Vocabulary.Keys.Verbs.LookAt], shoppingCart.avatar]
      priority: 1
      action: =>
        LOI.adventure.goToItem shoppingCart

  onExitAttempt: (exitResponse) ->
    hasCart = HQ.Items.ShoppingCart.state 'inInventory'
    return unless hasCart

    # Leaving counts as exiting to 2nd Street.
    return unless exitResponse.destinationLocationClass is SanFrancisco.Soma.SecondStreet

    @startScript label: 'LeavingWithCart'
    exitResponse.preventExit()
