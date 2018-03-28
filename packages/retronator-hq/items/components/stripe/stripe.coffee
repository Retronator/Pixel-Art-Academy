AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
RA = Retronator.Accounts
RS = Retronator.Store
HQ = Retronator.HQ

class HQ.Items.Components.Stripe extends LOI.Adventure.Item
  @PaymentMethods:
    StripeCustomer: 'Stripe' # Matches save payment method type.
    StripePayment: 'StripePayment'

  constructor: ->
    super

    @_actionModes =
      SaveCustomer: 'SaveCustomer'
      Payment: 'Payment'

  onCreated: ->
    super

    @stripeInitialized = new ReactiveField false
    @stripeEnabled = false

    @purchaseError = new ReactiveField null
    @submittingPayment = new ReactiveField false
    @purchaseCompleted = new ReactiveField false

    @selectedPaymentMethod = new ReactiveField null

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

    # See if we need to process the payment or it's simply a confirmation.
    paymentAmount = @paymentAmount()

    ga? 'send', 'event', 'Store Transaction', 'Initiated', 'Total', paymentAmount

    if paymentAmount
      return unless selectedPaymentMethod = @selectedPaymentMethod()

      if selectedPaymentMethod.paymentMethod.type is @constructor.PaymentMethods.StripeCustomer
        # We are using a stored payment method.
        @_payment
          paymentMethodId: selectedPaymentMethod.paymentMethod._id

      else
        # We are using a one-time payment, so process it with checkout.
        @_actionMode = @_actionModes.Payment

        @_stripeCheckout.open
          amount: paymentAmount * 100
          panelLabel: null

    else
      # The purchase does not need a payment, simply confirm the purchase.
      @_confirmationPurchaseHandler()

  _stripeResponseHandler: (token) ->
    # Strip token to id and email.
    token = _.pick token, ['id', 'email']

    switch @_actionMode
      when @_actionModes.SaveCustomer then @_saveCustomer token
      when @_actionModes.Payment then @_payment {token}

  _saveCustomer: (token) ->
    RS.PaymentMethod.insertStripe token.id, token.email

  _payment: (payment) ->
    # Start payment submission to the server.
    @submittingPayment true
    @_onSubmittingPayment?()

    # Clear the error they may have accrued.
    @purchaseError null

    # Create a payment on the server.
    shoppingCart = @_createShoppingCartObject()

    payment.amount = @paymentAmount()

    payment.europeanUnion = @country()
    payment.country = @country()
    payment.business = @business()
    payment.vatId = @vatId()
    
    Meteor.call RS.Transaction.insertStripePurchase, payment, shoppingCart, (error, data) =>
      @submittingPayment false

      if error
        @_displayError error
        return

      # Purchase is successfully completed.
      @_completePurchase shoppingCart, payment.amount

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
    @purchaseError error
