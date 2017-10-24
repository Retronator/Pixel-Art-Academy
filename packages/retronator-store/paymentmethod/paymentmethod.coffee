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
      user: @ReferenceField RA.User, ['displayName'], false

  @forCurrentUser: @subscription 'forCurrentUser'
  @addStripe: @method 'addStripe'

  @Types:
    Stripe: 'Stripe'
    PayPal: 'PayPal'
