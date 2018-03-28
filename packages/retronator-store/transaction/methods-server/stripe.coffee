AE = Artificial.Everywhere
AM = Artificial.Mummification
AT = Artificial.Telepathy
RS = Retronator.Store

Meteor.methods
  'Retronator.Store.Transaction.insertStripePurchase': (payment, shoppingCart) ->
    throw new AE.InvalidOperationException "Stripe has not been configured." unless AT.Stripe.initialized
    check payment, Match.ObjectIncluding
      token: Match.Optional
        id: String
        email: String
      paymentMethodId: Match.Optional Match.DocumentId
      amount: Number
      europeanUnion: Boolean
      country: Match.Optional String
      business: Match.Optional Boolean
      vatId: Match.Optional String
    check shoppingCart, Match.ShoppingCart

    # Re-create the shopping cart from the plain object.
    shoppingCart = RS.ShoppingCart.fromDataObject shoppingCart

    # Determine price of shopping cart items.
    totalPrice = shoppingCart.totalPrice()

    # First of all, payment amount should not be more than what is in the shopping cart.
    throw new AE.ArgumentOutOfRangeException "A payment that exceeds the value of the shopping cart was attempted." if payment.amount > totalPrice

    # See if user has available existing credit and needs to apply it towards the purchase.
    user = Retronator.user()
    availableCreditAmount = user?.store.credit or 0

    needsCreditAmount = totalPrice - payment.amount

    # The purchase must fail if the user doesn't have enough credit available.
    throw new AE.InvalidOperationException "The purchase requires more store credit than the user has available." if needsCreditAmount > availableCreditAmount

    # Looks like there is enough credit available (or none required, so use as much as needed).
    usedCreditAmount = needsCreditAmount

    # Validate the shopping cart to make sure the user is eligible to purchase the items.
    shoppingCart.validate()

    # Stripe can only store key/value pairs so build a flat metadata object of shopping cart items.
    metadata =
      paymentAmount: payment.amount

    for cartItem, i in shoppingCart.items()
      metadata["item #{i}"] = "#{cartItem.item.catalogKey} — $#{cartItem.item.price}"

    chargeData =
      amount: payment.amount * 100 # cents
      currency: 'usd'
      description: 'Retronator Store purchase'
      statement_descriptor: 'Retronator'
      metadata: metadata

    # Set email for stripe's default receipt. Make sure the user even has a contact email,
    # since it can be logged in from Twitter where we don't receive an email.
    if user?.contactEmail
      chargeData.receipt_email = user.contactEmail

    else if payment.token?.email
      chargeData.receipt_email = payment.token.email

    # Also create customer data for the transaction.
    customer = {}
    customer.email = chargeData.receipt_email if chargeData.receipt_email

    # Set payment source.
    if payment.paymentMethodId
      paymentMethod = RS.PaymentMethod.documents.findOne payment.paymentMethodId
      paymentMethodUser = paymentMethod.findUserForPaymentMethod()

      throw new AE.ArgumentException "Provided payment method does not belong to the user." unless paymentMethodUser._id is user._id
      chargeData.customer = paymentMethod.customerId

    else if payment.token
      # Create a stripe charge using the token.
      chargeData.source = payment.token.id

    else
      throw new AE.ArgumentNullException "You must provide either a payment method id or a stripe token."

    # Create a stripe charge.
    try
      stripeCharge = AT.Stripe.charges.create chargeData

    catch error
      throw new AE.InvalidOperationException "Stripe charge did not succeed.", error.message

    # Double check that the stripe charge was created.
    throw new AE.InvalidOperationException "Stripe charge was not created successfully." unless stripeCharge?.id

    # Double check that the charge succeeded.
    throw new AE.InvalidOperationException "Stripe charge did not succeed.", stripeCharge.failure_message unless stripeCharge.paid and stripeCharge.status is 'succeeded'

    # IMPORTANT: At this point the stripe charge was created, so any future thrown
    # errors need to have a special error code and be sent to the admin email.

    # Stripe charge was created so record the payment.
    payments = []

    stripePaymentId = RS.Payment.documents.insert
      type: RS.Payment.Types.StripePayment
      chargeId: stripeCharge.id
      amount: payment.amount

    stripePayment = RS.Payment.documents.findOne stripePaymentId

    unless stripePayment
      error = new Meteor.Error RS.Transaction.serverErrorAfterPurchase, "Stripe payment was not created successfully."
      emailAdminAboutError error, stripeCharge, payment, user
      throw error

    payments.push stripePayment

    if usedCreditAmount
      creditPaymentId = RS.Payment.documents.insert
        type: RS.Payment.Types.StoreCredit
        amount: 0
        storeCreditAmount: usedCreditAmount

      creditPayment = RS.Payment.documents.findOne creditPaymentId

      unless creditPayment
        error = new Meteor.Error RS.Transaction.serverErrorAfterPurchase, "Credit payment was not created successfully."
        emailAdminAboutError error, stripeCharge, payment, user
        throw error

      payments.push creditPayment

    # Finally try to complete the transaction.
    try
      transactionId = RS.Transaction.create
        customer: customer
        payments: payments
        shoppingCart: shoppingCart

    catch error
      # Log the error since we'll probably need to resolve the stripe payment.
      console.error "Transaction was not completed successfully.", error
      console.error "The stripe charge affected has id:", stripeCharge.id

      error = new Meteor.Error RS.Transaction.serverErrorAfterPurchase, "An error was encountered during creation of the transaction.", (error.reason or error.message or error)
      emailAdminAboutError error, stripeCharge, payment, user
      throw error

    # Return the transaction id if all went good.
    transactionId

emailAdminAboutError = (error, stripeCharge, payment, user) ->
  adminEmail = new AT.EmailComposer
  adminEmail.addParagraph "Error was encountered during Stripe purchase, after a charge was made."
  adminEmail.addParagraph "Error: #{error.reason} #{error.details}"
  adminEmail.addParagraph "User ID: #{user._id}" if user
  adminEmail.addParagraph "Charge ID: #{stripeCharge.id}" if user
  adminEmail.addParagraph "Payment token email: #{payment.token.email}" if payment.token
  adminEmail.addParagraph "Payment method: #{payment.paymentMethodId}" if payment.paymentMethodId
  adminEmail.end()

  Email.send
    from: "hi@retronator.com"
    to: "hi@retronator.com"
    subject: "Store purchase error"
    text: adminEmail.text
    html: adminEmail.html
