AB = Artificial.Babel
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

    # Collect evidence of customer's country.
    if payment.europeanUnion
      throw new AE.ArgumentOutOfRangeException "You must provide a country if you are in the EU." unless _.isString payment.country

      country = payment.country.toLowerCase()

      unless country in AB.Region.Lists.EuropeanUnion
        throw new AE.ArgumentOutOfRangeException "The provided country '#{country}' is not a member of the EU."

    else
      country = RS.Payment.NonEUCountryCode

    # Evidence #2 is the country of the payment method.
    if chargeData.source
      tokenEvidence = AT.Stripe.tokens.retrieve chargeData.source
      country2 = tokenEvidence.card.country.toLowerCase()

    else
      customerEvidence = AT.Stripe.customers.retrieve chargeData.customer
      country2 = customerEvidence.sources.data[0].country.toLowerCase()

    normalizeCountryCode = (countryCode) =>
      if countryCode in AB.Region.Lists.EuropeanUnion then countryCode else RS.Payment.NonEUCountryCode

    # Normalize non-EU countries.
    normalizedCountry2 = normalizeCountryCode country2

    unless country is normalizedCountry2
      # The countries do not match, so we need to collect third piece of evidence, which is the location of the IP.
      ip = tokenEvidence?.client_ip or @connection.clientAddress

      try
        country3 = AT.MaxMind.countryForIp ip

      catch error
        console.error "MaxMind error", error.message
        throw new AE.ArgumentException "Your chosen country does not match your credit card (#{country2.toUpperCase()})
                                        and we aren't able to check if the country based on your IP address matches instead."

      normalizedCountry3 = normalizeCountryCode country3

      unless country is normalizedCountry3
        throw new AE.ArgumentException "Your chosen country does not match your credit card (#{country2.toUpperCase()})
                                        or IP address (#{country3.toUpperCase()})."

    # European business needs a valid VAT ID.
    if payment.europeanUnion and payment.business
      vatIdCountry = payment.vatId[0..1].toLowerCase()
      vatIdCountry = 'gr' if vatIdCountry is 'el'

      throw new AE.ArgumentException "VAT ID doesn't match your country selection." unless vatIdCountry is country

      businessInfo = RS.Vat.validateVatId payment.vatId

    # Add VAT amounts to metadata. VAT is always charged in Slovenia and for EU consumers outside Slovenia.
    chargeVat = country is 'si' or payment.europeanUnion and not payment.business

    desiredVatPayment =
      usdToEurExchangeRate: RS.Vat.ExchangeRate.getUsdToEur()
      desiredTotalAmountUsd: payment.amount
      # We still do the VAT calculation, even if we don't charge VAT, so we get the
      # taxable amount calculated in EUR as needed for reporting to EU and SI.
      vatRate: if chargeVat then RS.Vat.Rates.Standard[country] else 0

    vatPayment = RS.Vat.calculateVat desiredVatPayment

    # Add all VAT fields to metadata.
    _.extend chargeData.metadata, vatPayment

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

    # Create the Stripe payment.
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

    # Create the store credit payment.
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
      
    # Build the tax info field.
    taxInfo =
      country:
        billing: country
        payment: country2

    if country3
      taxInfo.country.access = country3
      taxInfo.accessIp = ip

    if vatPayment
      taxInfo.vatRate = vatPayment.vatRate
      taxInfo.usdToEurExchangeRate = vatPayment.usdToEurExchangeRate
      taxInfo.amountEur =
        net: vatPayment.netAmountEur
        vat: vatPayment.vatAmountEur

    if businessInfo
      taxInfo.business =
        vatId: "#{businessInfo.countryCode}#{businessInfo.vatNumber}"
        name: businessInfo.name
        address: businessInfo.address

    # Try to complete the transaction.
    try
      transactionId = RS.Transaction.create
        customer: customer
        payments: payments
        shoppingCart: shoppingCart
        taxInfo: taxInfo

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
