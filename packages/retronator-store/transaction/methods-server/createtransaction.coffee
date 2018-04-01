AE = Artificial.Everywhere
RS = Retronator.Store

RS.Transaction.create = (options) ->
  {customer, payments, shoppingCart, taxInfo} = options

  transaction =
    time: new Date()
    items: []
    payments: _.pick payment, '_id' for payment in payments
    accessSecret: Random.id()

  if taxInfo
    transaction.taxInfo = taxInfo

    # Generate the next sequential invoice ID.
    invoiceYear = transaction.time.getUTCFullYear()
    lastVatTransaction = RS.Transaction.documents.findOne
      'taxInfo.invoiceId.year': invoiceYear
    ,
      sort:
        'taxInfo.invoiceId.number': -1
        
    lastInvoiceNumber = lastVatTransaction?.taxInfo.invoiceId.number or 0
    transaction.taxInfo.invoiceId =
      year: invoiceYear
      number: lastInvoiceNumber + 1

  if shoppingCart.tipAmount()
    transaction.tip =
      amount: shoppingCart.tipAmount()

    if shoppingCart.tipMessage()
      transaction.tip.message = _.truncate shoppingCart.tipMessage(),
        length: 100
        omission: '…'

  user = Retronator.user()
  
  if user
    # This is a purchase by a logged-in user, so simply record the id into the transaction.
    transaction.user =
      _id: user._id

    # Also prepare the customer object (if needed) with user info.
    options.customer ?= {}
    options.customer.name ?= user.displayName
    options.customer.email ?= user.contactEmail

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
  transactionId = RS.Transaction.documents.insert transaction

  # Finally send an email confirmation to the customer.
  try
    RS.Transaction.emailCustomer options

  catch error
    # We don't really want to throw an exception if only the emailing part failed.
    console.error "Error while emailing customer about the transaction", error
      
  # Return transactionId if it was created successfully.
  transactionId
