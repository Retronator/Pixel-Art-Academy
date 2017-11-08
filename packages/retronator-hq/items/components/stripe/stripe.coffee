AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
RA = Retronator.Accounts
RS = Retronator.Store
HQ = Retronator.HQ

class HQ.Items.Components.Stripe extends LOI.Adventure.Item
  constructor: ->
    super

    @_actionModes =
      SaveCustomer: 'SaveCustomer'
      OneTimePayment: 'OneTimePayment'

  onCreated: ->
    super

    @stripeInitialized = new ReactiveField false
    @stripeEnabled = false

    @purchaseError = new ReactiveField null
    @submittingPayment = new ReactiveField false
    @purchaseCompleted = new ReactiveField false

  onRendered: ->
    super

    if Meteor.settings.public.stripe?.publishableKey
      @stripeEnabled = true

      initializeStripeInterval = Meteor.setInterval =>
        # Wait until checkout is ready.
        return unless StripeCheckout?

        Meteor.clearInterval initializeStripeInterval

        @_stripeCheckout = StripeCheckout.configure
          key: Meteor.settings.public.stripe.publishableKey
          token: (token) => @_stripeResponseHandler token
          image: '/retronator/hq/items/receipt/stripe-marketplace-icon.png'
          name: 'Retronator'
          locale: 'auto'

        @stripeInitialized true
      ,
        100

    else
      console.warn "Set Stripe public and secret key in the settings file if you want to enable Stripe purchases."

  onDestroyed: ->
    super

    # Clean up after stripe checkout.
    @_stripeCheckout?.close()
    $('.stripe_checkout_app').remove()

  submitPaymentButtonAttributes: ->
    disabled: true if @submittingPayment()
    
  tip: ->
    amount: 0
    message: null

  supporterName: -> null

  events: ->
    super.concat
      'click .save-customer-button': @onClickSaveCustomerButton
      'click .submit-payment-button': @onClickSubmitPaymentButton

  onClickSaveCustomerButton: (event) ->
    @_actionMode = @_actionModes.SaveCustomer

    @_stripeCheckout.open
      amount: null
      panelLabel: 'Add card'

  onClickSubmitPaymentButton: (event) ->
    event.preventDefault()

    @_actionMode = @_actionModes.OneTimePayment

    # See if we need to process the payment or it's simply a confirmation.
    paymentAmount = @paymentAmount()

    ga? 'send', 'event', 'Store Transaction', 'Initiated', 'Total', paymentAmount

    if paymentAmount
      # The user needs to make a payment, so open checkout.
      @_stripeCheckout.open
        amount: paymentAmount * 100
        panelLabel: null

    else
      # The purchase does not need a payment, simply confirm the purchase.
      @_confirmationPurchaseHandler()

  _stripeResponseHandler: (token) ->
    switch @_actionMode
      when @_actionModes.SaveCustomer then @_saveCustomer token
      when @_actionModes.OneTimePayment then @_oneTimePayment token

  _saveCustomer: (token) ->
    RS.PaymentMethod.insertStripe token.id, token.email

  _oneTimePayment: (token) ->
    # Start payment submission to the server.
    @submittingPayment true
    @_onSubmittingPayment?()

    # Clear the error they may have accrued.
    @purchaseError null

    # Get tokenized credit card info.
    creditCardToken = token.id

    # Get the customer details.
    customer =
      email: token.email

    # Create a payment on the server.
    shoppingCart = @_createShoppingCartObject()

    paymentAmount = @paymentAmount()

    Meteor.call RS.Transaction.insertStripePurchase, customer, creditCardToken, paymentAmount, shoppingCart, (error, data) =>
      @submittingPayment false

      if error
        @_displayError error
        return

      # Purchase is successfully completed.
      @_completePurchase shoppingCart, paymentAmount

  _createShoppingCartObject: ->
    items: @purchaseItems()
    supporterName: @supporterName()
    tip: @tip()

  _completePurchase: (shoppingCart, paymentAmount) ->
    @purchaseCompleted true

    # Generate analytics events.
    ga? 'send', 'event', 'Store Transaction', 'Complete', 'Total', paymentAmount

    for cartItem in shoppingCart.items
      ga? 'send', 'event', 'Store Transaction', 'Item Purchased', cartItem.item.catalogKey, cartItem.item.price

  _confirmationPurchaseHandler: ->
    # Create a transaction on the server.
    @submittingPayment true
    @_onSubmittingPayment?()

    shoppingCart = @_createShoppingCartObject()

    Meteor.call 'Retronator.Store.Transaction.insertConfirmationPurchase', shoppingCart, (error, data) =>
      @submittingPayment false

      if error
        @_displayError error
        return

      # Purchase is successfully completed.
      console.log "ga", shoppingCart
      ga? 'send', 'event', 'Game Purchased', 'Click', shoppingCart.items[0].item.catalogKey, 0

      @_completePurchase shoppingCart, 0

  _displayError: (error) ->
    errorText = "Error: #{error.reason}"
    errorText = "#{errorText} #{error.details}" if error.details
    @purchaseError errorText
    console.error error
