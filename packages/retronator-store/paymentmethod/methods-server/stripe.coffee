AE = Artificial.Everywhere
AM = Artificial.Mummification
AT = Artificial.Telepathy
RS = Retronator.Store

RS.PaymentMethod.addStripe.method (creditCardToken, email) ->
  throw new AE.InvalidOperationException "Stripe has not been configured." unless AT.Stripe.initialized
  check creditCardToken, String
  check email, String

  user = Retronator.user()
  throw new AE.UnauthorizedException "Only users can add payment methods." unless user
  
  stripeCustomer = AT.Stripe.customers.create
    source: creditCardToken
    email: email

  # Double check that the stripe customer was created.
  throw new AE.InvalidOperationException "Stripe customer was not created successfully." unless stripeCustomer?.id

  # Stripe customer is created so add the payment method.
  paymentMethodId = RS.PaymentMethod.documents.insert
    type: RS.PaymentMethod.Types.Stripe
    user:
      _id: user._id
    customerId: stripeCustomer.id

  paymentMethod = RS.PaymentMethod.documents.findOne paymentMethodId
  unless paymentMethod
    console.error "Payment method was not created successfully."
    console.error "The stripe customer affected has id:", stripeCustomer.id
    throw new AE.InvalidOperationException "Payment method was not created successfully."
