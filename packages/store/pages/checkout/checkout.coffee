AB = Artificial.Babel
AM = Artificial.Mirage
RA = Retronator.Accounts
RS = Retronator.Store

class RS.Pages.Checkout extends AM.Component
  @register 'Retronator.Store.Pages.Checkout'
  
  onCreated: ->
    super

    @subscribe 'Retronator.Accounts.Transactions.Item.all'
    @subscribe 'Retronator.Accounts.Transactions.Transaction.forCurrentUser'
    @subscribe 'Retronator.Accounts.Transactions.Transaction.topRecent'
    @subscribe 'Retronator.Accounts.User.loginServicesForCurrentUser'
    @subscribe 'Retronator.Accounts.User.registeredEmailsForCurrentUser'

    @showSupporterNameForLoggedOut = new ReactiveField true

    @purchaseError = new ReactiveField null
    @submittingPayment = new ReactiveField false
    @purchaseCompleted = new ReactiveField false

    @_userBabelSubscription = AB.subscribeNamespace 'Retronator.Accounts.User'

  showSupporterName: ->
    if Meteor.userId()
      Retronator.user().profile?.showSupporterName

    else
      @showSupporterNameForLoggedOut()

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
    user = Retronator.user()
    return 0 unless user

    # Credit is applied up to the amount in the shopping cart.
    Math.min user.storeCredit(), RS.shoppingCart.totalPrice()

  paymentAmount: ->
    # See how much the user will need to pay to complete this transaction, after the credit is applied.
    storeCredit = Retronator.user()?.storeCredit() ? 0

    # Existing store credit decreases the needed amount to pay, but of course not below zero.
    Math.max 0, RS.shoppingCart.totalPrice() - storeCredit

  events: ->
    super.concat
      'change .anonymous-checkbox': @onChangeAnonymousCheckbox
      'input .supporter-name': @onInputSupporterName
      'input .tip-amount': @onInputTipAmount
      'input .tip-message': @onInputTipMessage
      'submit .payment-form': @onSubmitPaymentForm

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

  onSubmitPaymentForm: (event) ->
    event.preventDefault()

    # See if we need to process the payment or it's simply a confirmation.
    paymentAmount = @paymentAmount()
    @_handleSimplePaymentConfirmation() unless paymentAmount

    # Grab all customer inputs needed to tokenize credit card
    stripeTokenParameters = 
      name: @$('.name-on-card').val()
      number: @$('.card-number').val()
      cvc: @$('.cvc').val()
      exp_month: @$('.expiration-month').val()
      exp_year: @$('.expiration-year').val()

    # Perform preliminary validation on the client.
    unless Stripe.card.validateCardNumber stripeTokenParameters.number
      @purchaseError "Invalid card number."
      return

    unless Stripe.card.validateExpiry stripeTokenParameters.exp_month, stripeTokenParameters.exp_year
      @purchaseError "Invalid expiry date."
      return

    unless Stripe.card.validateCVC stripeTokenParameters.cvc
      @purchaseError "Invalid CVC."
      return

    # Validation has passed, go ahead and create the token.
    @submittingPayment true

    Stripe.card.createToken stripeTokenParameters, (status, response) =>
      @_stripeResponseHandler status, response

  _stripeResponseHandler: (status, response) ->
    # If there's an error, let our user know and let them try again.
    if response.error
      @purchaseError response.error.message
      @submittingPayment false
      return

    # Clear the error they may have accrued.
    @purchaseError null

    # Get tokenized credit card info.
    creditCardToken = response.id

    # Get the customer details.
    customer =
      email: @$('.email').val()
      name: @$('.name-on-card').val()

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

  _handleSimplePaymentConfirmation: ->
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
