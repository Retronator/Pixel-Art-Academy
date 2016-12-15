AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
RA = Retronator.Accounts
RS = Retronator.Store
HQ = Retronator.HQ

class HQ.Items.Tablet.Apps.ShoppingCart.Receipt extends AM.Component
  @register 'Retronator.HQ.Items.Tablet.Apps.ShoppingCart.Receipt'

  constructor: (@options) ->
    super

  onCreated: ->
    super

    # Get all store items data.
    @subscribe RS.Transactions.Item.all

    # Get top recent transactions to display the supporters list.
    @subscribe RS.Transactions.Transaction.topRecent

    # Get store balance and credit so we know if credit can be applied (and the user charged less).
    @subscribe RA.User.storeDataForCurrentUser
    
    # Get user's contact email so we can pre-fill it in Stripe Checkout.
    @subscribe RA.User.contactEmailForCurrentUser

    @stripeInitialized = new ReactiveField false

    @_userBabelSubscription = AB.subscribeNamespace 'Retronator.Accounts.User'

    @purchaseError = new ReactiveField null
    @submittingPayment = new ReactiveField false
    @purchaseCompleted = new ReactiveField false

  onRendered: ->
    super

    console.log "on rendered", StripeCheckout?

    initializeStripeInterval = Meteor.setInterval =>
      # Wait until checkout is ready.
      console.log "ready?", StripeCheckout?
      return unless StripeCheckout?

      Meteor.clearInterval initializeStripeInterval

      @_stripeCheckout = StripeCheckout.configure
        key: Meteor.settings.public.stripe.publishableKey
        token: (token) => @_stripeResponseHandler token
        image: 'https://stripe.com/img/documentation/checkout/marketplace.png'
        name: 'Retronator'
        locale: 'auto'

      @stripeInitialized true
    ,
      1

  onDestroyed: ->
    super

    # Clean up after stripe checkout.
    @_stripeCheckout.close()
    $('.stripe_checkout_app').remove()

  state: ->
    @options.shoppingCart.state()

  showSupporterName: ->
    user = Retronator.user()

    if user then user.profile?.showSupporterName else @state().showSupporterName

  supporterName: ->
    return unless @showSupporterName()

    user = Retronator.user()

    if user then user.profile.supporterName else @state().supporterName

  anonymousCheckboxAttributes: ->
    checked: true unless @showSupporterName()

  receiptItems: ->
    for receiptItem in @state().contents
      item = RS.Transactions.Item.documents.findOne catalogKey: receiptItem.item
      continue unless item

      item: item
      isGift: receiptItem.isGift
    
  itemsPrice: ->
    # The sum of all items to be purchased.
    _.sum (storeItem.item.price for storeItem in @receiptItems())

  totalPrice: ->
    # Total is the items price with added tip.
    @itemsPrice() + (@state().tip.amount or 0)

  creditApplied: ->
    storeCredit = Retronator.user()?.store?.credit or 0

    # Credit is applied up to the amount in the shopping cart.
    Math.min storeCredit, @totalPrice()

  paymentAmount: ->
    # See how much the user will need to pay to complete this transaction, after the credit is applied.
    storeCredit = Retronator.user()?.store?.credit or 0

    # Existing store credit decreases the needed amount to pay, but of course not below zero.
    Math.max 0, @totalPrice() - storeCredit

  topRecentTransactions: ->
    # First get the existing top 10.
    recentTransactions = RS.Components.TopSupporters.topRecentTransactions.find({},
      sort: [
        ['amount', 'desc']
        ['time', 'desc']
      ]
    ).fetch()

    # Mark as existing transactions.
    transaction.existing = true for transaction in recentTransactions

    # Create new transaction.
    newTransaction =
      name: @supporterName()
      amount: @totalPrice()
      new: true

    newTransaction.message = @state().tip.message if @state().tip.amount

    # Find where the new transaction needs to be inserted. We use
    # a negative amount because the list is in descending order.
    insertIndex = _.sortedIndexBy recentTransactions, newTransaction, (transaction) -> -transaction.amount

    # Add the new transaction and return the result.
    recentTransactions.splice insertIndex, 0, newTransaction
    recentTransactions

  submitPaymentButtonAttributes: ->
    disabled: true if @submittingPayment()

  events: ->
    super.concat
      'change .anonymous-checkbox': @onChangeAnonymousCheckbox
      'input .supporter-name': @onInputSupporterName
      'input .tip-amount': @onInputTipAmount
      'input .tip-message': @onInputTipMessage
      'click .submit-payment-button': @onClickSubmitPaymentButton

  onChangeAnonymousCheckbox: (event) ->
    if Meteor.userId()
      Meteor.call "Retronator.Accounts.User.setShowSupporterName", not event.target.checked

    else
      @state().showSupporterName = not event.target.checked
      @options.adventure.gameState.updated()

  onInputSupporterName: (event) ->
    name = $(event.target).val()
    @state().supporterName = name
    @options.adventure.gameState.updated()

  onInputTipAmount: (event) ->
    enteredString = $(event.target).val()

    # Make sure the entered value is a number.
    try
      enteredValue = parseFloat enteredString

    catch
      enteredValue = 0

    # If negative sign is entered the parsing succeeds with a NaN value.
    enteredValue = 0 if _.isNaN enteredValue

    # Constrain to non-negative numbers and round to dollar amount.
    value = Math.floor Math.max 0, enteredValue

    # Rewrite the value in the input if needed.
    newString = "#{value}"
    $(event.target).val newString unless newString is enteredString

    @state().tip.amount = value
    @options.adventure.gameState.updated()

  onInputTipMessage: (event) ->
    message = $(event.target).val()
    @state().tip.message = message
    @options.adventure.gameState.updated()

  onClickSubmitPaymentButton: (event) ->
    event.preventDefault()

    # See if we need to process the payment or it's simply a confirmation.
    paymentAmount = @paymentAmount()

    if paymentAmount
      # The user needs to make a payment, so open checkout.
      @_stripeCheckout.open
        amount: paymentAmount * 100

    else
      # The purchase does not need a payment, simply confirm the purchase.
      @_confirmationPurchaseHandler()

  _stripeResponseHandler: (token) ->
    # Clear the error they may have accrued.
    @purchaseError null

    # Get tokenized credit card info.
    creditCardToken = token.id

    # Get the customer details.
    customer =
      email: token.email

    # Create a payment on the server.
    shoppingCart = @_createShoppingCartObject()

    Meteor.call 'Retronator.Store.Transactions.Transaction.insertStripePurchase', customer, creditCardToken, @paymentAmount(), shoppingCart, (error, data) =>
      @submittingPayment false

      if error
        @_displayError error
        return

      # Purchase is successfully completed.
      @purchaseCompleted true

      # Clear all inserted payment info.
      @$('.payment-form input').val('')

      # Remove all purchased items from the shopping cart.
      @_emptyShoppingCart()

  _createShoppingCartObject: ->
    items: @receiptItems()
    supporterName: @state().supporterName
    tip: @state().tip

  _emptyShoppingCart: ->
    store = @options.adventure.gameState().locations[HQ.Locations.Store.id()]
    shoppingCart = store.things[HQ.Locations.Store.ShoppingCart.id()]

    shoppingCart.contents = []

    @options.adventure.gameState.updated()

  _confirmationPurchaseHandler: ->
    # Create a transaction on the server.
    @submittingPayment true

    shoppingCart = @_createShoppingCartObject()

    Meteor.call 'Retronator.Store.Transactions.Transaction.insertConfirmationPurchase', shoppingCart, (error, data) =>
      @submittingPayment false

      if error
        @_displayError error
        return

      # Purchase is successfully completed.
      @purchaseCompleted true

      # Clear all inserted payment info.
      @$('.payment-form input').val('')

      # Reset the shopping cart.
      @_emptyShoppingCart()

  _displayError: (error) ->
    errorText = "Error: #{error.reason}"
    errorText = "#{errorText} #{error.details}" if error.details
    @purchaseError errorText
