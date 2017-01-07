AE = Artificial.Everywhere
AM = Artificial.Mummification
RS = Retronator.Store

Meteor.methods
  # A purchase that only needed to be confirmed (called) by the
  # user. Any payment amount is provided by available store credit.
  'Retronator.Store.Transactions.Transaction.insertConfirmationPurchase': (shoppingCart) ->
    check shoppingCart, Match.ShoppingCart

    # Re-create the shopping cart from the plain object.
    shoppingCart = RS.Transactions.ShoppingCart.fromDataObject shoppingCart

    # Determine price of shopping cart items.
    totalPrice = shoppingCart.totalPrice()

    # See if user has available existing credit and needs to apply it towards the purchase.
    user = Retronator.user()
    availableCreditAmount = user?.store?.credit or 0

    needsCreditAmount = totalPrice

    # The purchase must fail if the user doesn't have enough credit available.
    throw new AE.InvalidOperationException "The purchase requires more store credit than the user has available." if needsCreditAmount > availableCreditAmount

    # Looks like there is enough credit available (or none required, so use as much as needed).
    usedCreditAmount = needsCreditAmount

    # Validate the shopping cart to make sure the user is eligible to purchase the items.
    shoppingCart.validate()

    # Record the payment.
    payments = []

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
        payments: payments
        shoppingCart: shoppingCart

    catch error
      # Log the error since we'll probably need to resolve the stripe payment.
      console.error "Transaction was not completed successfully."
      throw error

    # Return the transaction id if all went good.
    transactionId
