AB = Artificial.Babel
AM = Artificial.Mirage
RA = Retronator.Accounts
RS = Retronator.Store

class RS.Pages.Checkout extends AM.Component
  @register 'Retronator.Store.Pages.Checkout'
  
  onCreated: ->
    super

    # Get all store items data.
    @subscribe 'Retronator.Accounts.Transactions.Item.all'

    # Get top recent transactions to display the supporters list.
    @subscribe 'Retronator.Accounts.Transactions.Transaction.topRecent'

    # Get store balance and credit so we know if credit can be applied (and the user charged less).
    @subscribe 'Retronator.Accounts.User.storeDataForCurrentUser'
    
    # Get user's contact email so we can pre-fill it in Stripe Checkout.
    @subscribe 'Retronator.Accounts.User.contactEmailForCurrentUser'

    @stripeInitialized = new ReactiveField false

    @showSupporterNameForLoggedOut = new ReactiveField true

    @purchaseError = new ReactiveField null
    @submittingPayment = new ReactiveField false
    @purchaseCompleted = new ReactiveField false

    @_userBabelSubscription = AB.subscribeNamespace 'Retronator.Accounts.User'

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

  showSupporterName: ->
    user = Retronator.user()

    if user then user.profile?.showSupporterName else @showSupporterNameForLoggedOut()

  supporterName: ->
    return unless @showSupporterName()

    user = Retronator.user()

    if user then user.profile.supporterName else RS.shoppingCart.supporterName()

  anonymousCheckboxAttributes: ->
    checked: true unless @showSupporterName()

  shoppingCart: ->
    RS.shoppingCart

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
      amount: RS.shoppingCart.totalPrice()
      new: true

    newTransaction.message = RS.shoppingCart.tipMessage() if RS.shoppingCart.tipAmount()

    # Find where the new transaction needs to be inserted. We use
    # a negative amount because the list is in descending order.
    insertIndex = _.sortedIndexBy recentTransactions, newTransaction, (transaction) -> -transaction.amount

    # Add the new transaction and return the result.
    recentTransactions.splice insertIndex, 0, newTransaction
    recentTransactions

  anonymousPlaceholder: ->
    AB.translate(@_userBabelSubscription, 'Anonymous').text

  submitPaymentButtonAttributes: ->
    disabled: true if @submittingPayment()

  creditApplied: ->
    storeCredit = Retronator.user()?.store?.credit or 0

    # Credit is applied up to the amount in the shopping cart.
    Math.min storeCredit, RS.shoppingCart.totalPrice()

  paymentAmount: ->
    # See how much the user will need to pay to complete this transaction, after the credit is applied.
    storeCredit = Retronator.user()?.store?.credit or 0

    # Existing store credit decreases the needed amount to pay, but of course not below zero.
    Math.max 0, RS.shoppingCart.totalPrice() - storeCredit

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
      @showSupporterNameForLoggedOut not event.target.checked

  onInputSupporterName: (event) ->
    name = $(event.target).val()
    RS.shoppingCart.supporterName name

  onInputTipAmount: (event) ->
    # Make sure the entered value is a number.
    try
      enteredValue = parseFloat $(event.target).val()

    catch
      enteredValue = 0

    # Constrain to non-negative numbers.
    value = Math.max 0, enteredValue

    RS.shoppingCart.tipAmount value

  onInputTipMessage: (event) ->
    message = $(event.target).val()
    RS.shoppingCart.tipMessage message

  onClickSubmitPaymentButton: (event) ->
    event.preventDefault()

    # See if we need to process the payment or it's simply a confirmation.
    paymentAmount = @paymentAmount()

    if paymentAmount
      # The user needs to make a payment, so open checkout.
      @_stripeCheckout.open
        description: 'Things you are buying: 1\n, 2, 3'
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
    Meteor.call 'Retronator.Accounts.Transactions.Transaction.insertStripePurchase', customer, creditCardToken, @paymentAmount(), RS.shoppingCart.toDataObject(), (error, data) =>
      @submittingPayment false

      if error
        @_displayError error
        return

      # Purchase is successfully completed.
      @purchaseCompleted true

      # Clear all inserted payment info.
      @$('.payment-form input').val('')

      # Remove all purchased items from the shopping cart.
      RS.shoppingCart.reset()

  _confirmationPurchaseHandler: ->
    # Create a transaction on the server.
    @submittingPayment true

    Meteor.call 'Retronator.Accounts.Transactions.Transaction.insertConfirmationPurchase', RS.shoppingCart.toDataObject(), (error, data) =>
      @submittingPayment false

      if error
        @_displayError error
        return

      # Purchase is successfully completed.
      @purchaseCompleted true

      # Clear all inserted payment info.
      @$('.payment-form input').val('')

      # Reset the shopping cart.
      RS.shoppingCart.reset()

  _displayError: (error) ->
    errorText = "Error: #{error.reason}"
    errorText = "#{errorText} #{error.details}" if error.details
    @purchaseError errorText
