AE = Artificial.Everywhere
AT = Artificial.Telepathy
RA = Retronator.Accounts
RS = Retronator.Store

RS.Pages.Admin.AuthorizedPayments.sendAllReminderEmails.method ->
  RA.authorizeAdmin()

  console.log "Sending reminder emails for all transactions with authorized-only payments."

  transactions = RS.Transaction.documents.find('payments.authorizedOnly': true).fetch()

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

  # Find transaction and make sure it has an authorized-only payment.
  transaction = RS.Transaction.documents.findOne
    _id: transactionId
    'payments.authorizedOnly': true

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
    "#{item.name.refresh().translate().text} $#{item.price}"

  date = transaction.time.toLocaleString 'en-US',
    day: 'numeric'
    month: 'long'
    year: 'numeric'

  email.addParagraph "On #{date} you placed a purchase order for:\n
                      #{itemNamesList.join '\n'}"

  email.addParagraph "You also added a tip of $#{transaction.tip.amount}. Thank you!" if transaction.tip?.amount

  for payment in transaction.payments
    switch payment.type
      when RS.Payment.Types.StripePayment
        email.addParagraph "At that time we only collected your credit card information.
                          Your payment of $#{payment.amount} will now be processed, early next week."

  email.addParagraph "As promised, this acts as a reminder email, in case you want to cancel your pre-order.
                      I wrote an explanation article that details where the development is right now.
                      It has all the information you need as well as an extensive FAQ."

  email.addLinkParagraph 'https://medium.com/@retronator/pixel-art-academy-pre-order-information-ef73d5b99ae7', "Pixel Art Academy pre-order information"

  email.addParagraph "If you have any questions or you would like to cancel your pre-order, simply reply to this email.
                      No reason needs to be given for cancellation—I appreciate your support as it is."

  email.addParagraph "If you decide to stay on board, thank you so much! No action needs to be taken on your part.
                      After the payment is processed next week you will get a confirmation email from our credit card
                      processor Stripe. Your information is safely stored with them."

  email.addParagraph "If you want to check the status of your credit card or change it, refer to the FAQ above."

  email.addParagraph "Thank you again. I hope you will enjoy the game as it grows in the years to come."

  email.addParagraph "Best,\n
                      Matej 'Retro' Jan // Retronator"

  email.end()

  Email.send
    from: "hi@retronator.com"
    to: address
    subject: "Retronator Store - Pixel Art Academy pre-order reminder"
    text: email.text
    html: email.html

  console.log "Retronator Store pre-order reminder email sent to", address

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
