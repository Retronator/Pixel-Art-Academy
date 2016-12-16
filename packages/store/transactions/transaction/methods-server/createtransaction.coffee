RS = Retronator.Store

RS.Transactions.Transaction.create = (options) ->
  {customer, payments, shoppingCart} = options

  transaction =
    time: new Date()
    items: []
    payments: _.pick payment, '_id' for payment in payments

  if shoppingCart.tipAmount()
    transaction.tip =
      amount: shoppingCart.tipAmount()

    transaction.tip.message = shoppingCart.tipMessage() if shoppingCart.tipMessage()

  user = Retronator.user()
  
  if user
    # This is a purchase by a logged-in user, so simply record the id into the transaction.
    transaction.user =
      _id: user._id

    # Also prepare the customer object (if needed) with user info.
    options.customer ?= {}
    options.customer.name ?= user.displayName
    options.customer.email ?= user.emails[0]?.address

  else
    # The user is not logged in, so we expect to have the email ready.
    transaction.email = customer.email

    # For logged-out users, we store supporter name directly on transaction.
    transaction.supporterName = shoppingCart.supporterName() if shoppingCart.supporterName()

  for cartItem in shoppingCart.items()
    item =
      item:
        _id: cartItem.item._id
      price: cartItem.item.price

    if cartItem.isGift
      # Generate a random key code for the gifted item.
      item.givenGift =
        keyCode: Random.id()

    transaction.items.push item

  # Insert the purchase document for this transaction.
  transactionId = RS.Transactions.Transaction.documents.insert transaction

  # Finally send an email confirmation to the customer.
  try
    RS.Transactions.Transaction.emailCustomer options

  catch error
    # We don't really want to throw an exception if only the emailing part failed.
    console.error "Error while emailing customer about the transaction", error
      
  # Return transactionId if it was created successfully.
  transactionId
