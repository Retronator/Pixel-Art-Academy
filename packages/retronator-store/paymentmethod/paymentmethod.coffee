AM = Artificial.Mummification
RA = Retronator.Accounts
RS = Retronator.Store

class RS.PaymentMethod extends AM.Document
  @id: -> 'Retronator.Store.PaymentMethod'
  # type: what kind of payment method this is
  # removed: boolean to indicate the payment method has been removed by the user
  # user: optional user to which this payment method belongs to, if added directly by the user
  #   _id
  #   displayName
  #
  # STRIPE
  # customerId: customer id returned from stripe API
  @Meta
    name: @id()
    fields: =>
      user: Document.ReferenceField RA.User, ['displayName'], false

  # Methods
  
  @insertStripe: @method 'insertStripe'
  @removeStripe: @method 'removeStripe'

  @getStripeCustomerData: @method 'getStripeCustomerData'

  # Subscriptions
  
  @forCurrentUser: @subscription 'forCurrentUser'

  @Types:
    Stripe: 'Stripe'
    PayPal: 'PayPal'
    
  @findUserForPaymentMethod: (paymentMethod) ->
    return unless paymentMethod

    # Find the user of this payment method if possible. First, see if it is set directly.
    return RA.User.documents.findOne paymentMethod.user._id if paymentMethod.user?._id

    # Try and find payments that used this method.
    payments = RS.Payment.documents.find(
      'paymentMethod._id': paymentMethod._id
    ).fetch()
    
    for payment in payments
      # Find the transaction for this payment
      transaction = RS.Transaction.documents.findOne
        'payments._id': payment._id
        
      if transaction
        # See if we can determine the user for transaction.
        user = transaction.findUserForTransaction()
        return user if user

    # We couldn't find a user for this payment.
    null

  findUserForPaymentMethod: ->
    @constructor.findUserForPaymentMethod @

  @findPaymentMethodsForUser: (user) ->
    return unless user

    transactions = RS.Transaction.getValidTransactionsForUser user

    # Get all payments from transactions.
    paymentIds = for transaction in transactions when transaction.payments
      payment._id for payment in transaction.payments

    paymentIds = _.flatten paymentIds

    payments = RS.Payment.documents.find(
      _id:
        $in: paymentIds
    ).fetch()

    # Get all payment methods from transaction payments.
    transactionPaymentMethodIds = (payment.paymentMethod._id for payment in payments when payment.paymentMethod)

    # Get all payment methods belonging to the user.
    userPaymentMethods = RS.PaymentMethod.documents.find(
      'user._id': user._id
    ).fetch()

    userPaymentMethodIds = (paymentMethod._id for paymentMethod in userPaymentMethods)

    paymentMethodIds = _.union transactionPaymentMethodIds, userPaymentMethodIds

    # Return all payment methods without removed ones.
    RS.PaymentMethod.documents.find
      _id:
        $in: paymentMethodIds
      removed:
        $ne: true
    ,
      # Only return the type field, since that's all the client needs to display a list of payment methods.
      fields:
        type: 1
