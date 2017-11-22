AE = Artificial.Everywhere
AT = Artificial.Telepathy
RA = Retronator.Accounts
RS = Retronator.Store

RS.Pages.Admin.AuthorizedPayments.sendAllReminderEmails.method ->
  RA.authorizeAdmin()

  console.log "Sending reminder emails for all failed transactions with authorized-only payments."

  transactions = RS.Transaction.documents.find(
    invalid: true
    payments:
      $elemMatch:
        type: RS.Payment.Types.StripePayment
        authorizedOnly: true
  ).fetch()

  successCount = 0
  failureCount = 0

  for transaction in transactions
    try
      RS.Pages.Admin.AuthorizedPayments.sendReminderEmail transaction._id
      successCount++

    catch error
      console.error "Sending reminder email failed for transaction", transaction._id
      console.error error
      failureCount++

  console.log "Successfully sent #{successCount} emails, failed #{failureCount}."

RS.Pages.Admin.AuthorizedPayments.sendReminderEmail.method (transactionId) ->
  check transactionId, Match.DocumentId
  RA.authorizeAdmin()

  # Find invalid transaction and make sure it has an authorized-only payment.
  transaction = RS.Transaction.documents.findOne
    _id: transactionId
    invalid: true
    payments:
      $elemMatch:
        type: RS.Payment.Types.StripePayment
        authorizedOnly: true

  throw new AE.ArgumentException 'Transaction with a payment that is authorized only does not exist.' unless transaction

  # Find address to send the email to.
  if transaction.email
    address = transaction.email

  else if transaction.user
    user = RA.User.documents.findOne transaction.user._id

    throw new AE.ArgumentException 'Transaction user not found.' unless transaction

    address = user.contactEmail

  throw new AE.ArgumentException 'Transaction email address not found.' unless address

  email = new AT.EmailComposer

  if user?.publicName
    email.addParagraph "Hi #{user.publicName},"

  else
    email.addParagraph "Hi,"

  email.addParagraph "This is Matej from Retronator, creator of Pixel Art Academy."

  itemNamesList = for item in transaction.items
    item = RS.Item.documents.findOne item.item._id
    item.name.refresh().translate().text

  date = transaction.time.toLocaleString 'en-US',
    day: 'numeric'
    month: 'long'
    year: 'numeric'

  email.addParagraph "Recently I emailed you about the pre-order you placed on #{date} for:\n
                      #{itemNamesList.join '\n'}"

  email.addParagraph "I'm letting you know that your purchase was NOT processed successfully."

  for payment in transaction.payments
    payment = payment.refresh()
    switch payment.type
      when RS.Payment.Types.StripePayment
        # Make sure that the payment method hasn't been removed.
        paymentMethod = RS.PaymentMethod.documents.findOne payment.paymentMethod._id

        if paymentMethod.removed
          console.warn "Skipping", payment._id, address, payment.chargeError.failureMessage
          return

        email.addParagraph "The error was: #{payment.chargeError.failureMessage}"

  email.addParagraph "As a result, your pre-order has been canceled. If you would like to keep access to the game
                      and the lower pre-order price, you can simply make a new purchase in the game store that
                      you reach in 'Chapter 2: Retronator HQ' while playing the game at:"

  email.addLinkParagraph 'https://pixelart.academy'

  email.addParagraph "The lower pre-order price will be available at least until the end of the year.
                      If you have any questions, simply reply to this email."

  email.addParagraph "Thank you for your intended support and happy holidays!"

  email.addParagraph "Best,\n
                      Matej 'Retro' Jan // Retronator"

  email.end()

  Email.send
    from: "hi@retronator.com"
    to: address
    subject: "Retronator Store - Pixel Art Academy pre-order canceled"
    text: email.text
    html: email.html

  console.log "Retronator Store pre-order canceled email sent to", address

RS.Pages.Admin.AuthorizedPayments.chargeAllPayments.method ->
  RA.authorizeAdmin()

  console.log "Charging payments for all stripe transactions with authorized-only payments."

  transactions = RS.Transaction.documents.find(
    payments:
      $elemMatch:
        type: RS.Payment.Types.StripePayment
        authorizedOnly: true
        invalid: $ne: true
    invalid: $ne: true
  ).fetch()

  successCount = 0
  failureCount = 0

  for transaction in transactions
    try
      RS.Pages.Admin.AuthorizedPayments.chargePayment transaction._id
      successCount++

    catch error
      console.error "Charging payment failed for transaction", transaction._id, error.message, error.details
      failureCount++

  console.log "Successfully processed #{successCount} payments, failed #{failureCount}."

RS.Pages.Admin.AuthorizedPayments.chargePayment.method (transactionId) ->
  check transactionId, Match.DocumentId
  RA.authorizeAdmin()

  # Find transaction and make sure it has an authorized-only payment.
  transaction = RS.Transaction.documents.findOne
    _id: transactionId
    payments:
      $elemMatch:
        type: RS.Payment.Types.StripePayment
        authorizedOnly: true
        invalid: $ne: true
    invalid: $ne: true

  throw new AE.ArgumentException 'Valid transaction with a stripe payment that is authorized only does not exist.' unless transaction

  # Find payment method.
  for payment in transaction.payments when payment.type is RS.Payment.Types.StripePayment
    payment = payment.refresh()
    throw new AE.InvalidOperationException "Payment method not present on payment", payment._id unless payment.paymentMethod
    throw new AE.InvalidOperationException "Payment amount not present on payment", payment._id unless payment.amount

    paymentMethod = payment.paymentMethod.refresh()

    # Make sure we don't charge twice.
    if not payment.authorizedOnly or payment.chargeId or payment.chargeError or payment.invalid
      console.log "Skipping payment", payment._id, "authorized", payment.authorizedOnly, "has id", payment.chargeId?, "has error", payment.chargeError?
      continue

    # Make sure we don't charge removed payment methods.
    if paymentMethod.removed
      console.log "Primary payment method was removed for transaction", transaction._id

      updateRemovedPaymentMethodError = =>
        RS.Payment.documents.update payment._id,
          $set:
            chargeError:
              failureMessage: "Payment method was removed."
              failureCode: null

      # Try and find out another payment method for this user.
      user = paymentMethod.findUserForPaymentMethod()

      unless user
        console.warn "No user was found, skipping charge of", payment.amount
        updateRemovedPaymentMethodError()
        continue

      paymentMethod = RS.PaymentMethod.findPaymentMethodsForUser(user).fetch()[0]

      unless paymentMethod
        console.log "Replacement payment method was not found. Skipping charge of", payment.amount
        updateRemovedPaymentMethodError()
        continue

      # Refresh the payment method if found, since find function only returns _id and type.
      paymentMethod = paymentMethod.refresh()

      # Update payment to point to new payment method.
      RS.Payment.documents.update payment._id,
        $set:
          'paymentMethod._id': paymentMethod._id

    throw new AE.InvalidOperationException "Stripe customer not available on payment method." unless paymentMethod.customerId

    metadata =
      paymentAmount: payment.amount
      preAuthorizedPurchase: true
      paymentId: payment._id
      transactionId: transaction._id

    chargeData =
      amount: payment.amount * 100 # cents
      currency: 'usd'
      description: 'Retronator Store purchase'
      statement_descriptor: 'Retronator'
      metadata: metadata
      customer: paymentMethod.customerId

    # Set email for stripe's default receipt.
    user = paymentMethod.findUserForPaymentMethod()

    if user
      chargeData.receipt_email = user.contactEmail

    else
      chargeData.receipt_email = transaction.email

    # Make sure receipt email is set.
    throw new AE.InvalidOperationException "Receipt email not found for payment", payment._id unless chargeData.receipt_email

    # Prepare to record an error on the payment.
    recordError = (error) =>
      chargeError =
        failureMessage: error?.failure_message or error?.message or "Unknown error"
        failureCode: error?.failure_code or null

      console.log "Stripe charge did not succeed.", chargeError

      RS.Payment.documents.update payment._id,
        $set: {chargeError}

      throw new AE.InvalidOperationException "Stripe charge did not succeed.", chargeError.failureMessage

    # Create a stripe charge.
    console.log "Creating charge for payment", payment._id, "customer", chargeData.customer

    try
      stripeCharge = AT.Stripe.charges.create chargeData

    catch error
      recordError error

    # Double check that the stripe charge was created.
    recordError() unless stripeCharge?.id

    # Double check that the charge succeeded.
    recordError stripeCharge unless stripeCharge.paid and stripeCharge.status is 'succeeded'

    # Record that the payment was charged.
    RS.Payment.documents.update payment._id,
      $set:
        chargeId: stripeCharge.id
      $unset:
        authorizedOnly: true
