AE = Artificial.Everywhere
AM = Artificial.Mummification
AT = Artificial.Telepathy
RS = Retronator.Store

Meteor.methods
  'Retronator.Store.Transactions.Transaction.insertStripePurchase': (customer, creditCardToken, payAmount, shoppingCart) ->
    throw new AE.InvalidOperationException "Stripe has not been configured." unless AT.Stripe.initialized

    check customer, Match.OptionalOrNull Object
    check customer.email, String if customer?.email
    check creditCardToken, String
    check payAmount, Number
    check shoppingCart, Match.ShoppingCart

    # Re-create the shopping cart from the plain object.
    shoppingCart = RS.Transactions.ShoppingCart.fromDataObject shoppingCart

    # Determine price of shopping cart items.
    totalPrice = shoppingCart.totalPrice()

    # First of all, payment amount should not be more than what is in the shopping cart.
    throw new AE.ArgumentOutOfRangeException "A payment that exceeds the value of the shopping cart was attempted." if payAmount > totalPrice

    # See if user has available existing credit and needs to apply it towards the purchase.
    user = Retronator.user()
    availableCreditAmount = user?.store.credit or 0

    needsCreditAmount = totalPrice - payAmount

    # The purchase must fail if the user doesn't have enough credit available.
    throw new AE.InvalidOperationException "The purchase requires more store credit than the user has available." if needsCreditAmount > availableCreditAmount

    # Looks like there is enough credit available (or none required, so use as much as needed).
    usedCreditAmount = needsCreditAmount

    # Validate the shopping cart to make sure the user is eligible to purchase the items.
    shoppingCart.validate()

    # Stripe can only store key/value pairs so build a flat metadata object of shopping cart items.
    metadata =
      payAmount: payAmount

    for cartItem, i in shoppingCart.items()
      metadata["item #{i}"] = "#{cartItem.item.catalogKey} — $#{cartItem.item.price}"

    stripeCustomer = AT.Stripe.customers.create
      source: creditCardToken
      email: customer.email
      metadata: metadata

    # Double check that the stripe customer was created.
    throw new AE.InvalidOperationException "Stripe customer was not created successfully." unless stripeCustomer?.id

    # Stripe customer is created so record the payment.
    payments = []

    stripePaymentId = RS.Transactions.Payment.documents.insert
      type: RS.Transactions.Payment.Types.StripePayment
      stripeCustomerId: stripeCustomer.id
      amount: payAmount
      authorizedOnly: true

    stripePayment = RS.Transactions.Payment.documents.findOne stripePaymentId
    throw new AE.InvalidOperationException "Stripe payment was not created successfully." unless stripePayment

    payments.push stripePayment

    if usedCreditAmount
      creditPaymentId = RS.Transactions.Payment.documents.insert
        type: RS.Transactions.Payment.Types.StoreCredit
        amount: 0
        storeCreditAmount: usedCreditAmount

      creditPayment = RS.Transactions.Payment.documents.findOne creditPaymentId
      throw new AE.InvalidOperationException "Credit payment was not created successfully." unless creditPayment

      payments.push creditPayment

    # Finally try to complete the transaction.
    try
      transactionId = RS.Transactions.Transaction.create
        customer: customer
        payments: payments
        shoppingCart: shoppingCart

    catch error
      # Log the error since we'll probably need to resolve the stripe payment.
      console.error "Transaction was not completed successfully."
      console.error "The stripe customer affected has id:", stripeCustomer.id, " name:", customer?.name
      throw new AE.InvalidOperationException "An error was encountered during creation of the transaction."

    # Return the transaction id if all went good.
    transactionId
