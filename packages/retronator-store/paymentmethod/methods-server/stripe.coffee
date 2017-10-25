AE = Artificial.Everywhere
AM = Artificial.Mummification
AT = Artificial.Telepathy
RS = Retronator.Store

RS.PaymentMethod.insertStripe.method (creditCardToken, email) ->
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

getStripePaymentMethod = (paymentMethodId) ->
  paymentMethod = RS.PaymentMethod.documents.findOne paymentMethodId
  throw new AE.ArgumentException "Invalid payment method." unless paymentMethod

  currentUserId = Meteor.userId()
  user = paymentMethod.findUserForPaymentMethod()
  throw new AE.UnauthorizedException "User doesn't have permission to view this payment method." unless user?._id is currentUserId

  throw new AE.ArgumentException "Payment method is not a Stripe payment method." unless paymentMethod.customerId

  # Return the payment method.
  paymentMethod

RS.PaymentMethod.removeStripe.method (paymentMethodId) ->
  check paymentMethodId, Match.DocumentId

  paymentMethod = getStripePaymentMethod paymentMethodId

  # Delete customer from Stripe.
  result = AT.Stripe.customers.delete paymentMethod.customerId

  unless result.deleted
    console.error "Deleting stripe customer failed. Affected payment method:", paymentMethod
    throw new AE.InvalidOperationException "An error was encountered removing customer information."

  # Customer was successfully deleted from Stripe. We don't actually remove it from our DB but just clear its
  # data and set removed to true, so that payment references don't point to non-existing payment methods.
  RS.PaymentMethod.documents.update paymentMethod._id,
    $set:
      removed: true
    $unset:
      customerId: true

RS.PaymentMethod.getStripeCustomerData.method (paymentMethodId) ->
  check paymentMethodId, Match.DocumentId

  paymentMethod = getStripePaymentMethod paymentMethodId

  # Get customer data from Stripe.
  customerData = AT.Stripe.customers.retrieve paymentMethod.customerId

  # Return credit card info.
  creditCard = customerData.sources.data[0]
  throw new AE.ArgumentException "Payment method does not have credit card data." unless creditCard

  name: creditCard.name
  expiration:
    month: creditCard.exp_month
    year: creditCard.exp_year
  number: creditCard.last4
  brand: creditCard.brand
