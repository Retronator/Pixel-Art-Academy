AM = Artificial.Mummification
RA = Retronator.Accounts
RS = Retronator.Store

class RS.Payment extends AM.Document
  @id: -> 'Retronator.Store.Payment'
  # type: what kind of payment this was
  # amount: USD value added to the balance with this payment
  # authorizedOnly: true if the amount was not actually collected and this is just an intended payment
  # invalid: auto-generated boolean that voids this payment
  # paymentMethod:
  #   _id
  #
  # KICKSTARTER PLEDGE
  # backerEmail: Kickstarter user's email who made the pledge
  # project: name of the project the pledge is associated with
  # backerNumber: kickstarter backer number
  # backerId: kickstarter backer UID
  # backerName: kickstarter backer Name
  #
  # PATREON PLEDGE
  # patronEmail: Patreon user's email when processing the pledge
  # patronId: Patreon user ID
  #
  # STRIPE PAYMENT
  # chargeId: charge id returned from stripe API
  # chargeError: error that occurred while trying to charge this payment (after being only authorized)
  #   failureCode: code returned directly from stripe
  #   failureMessage: message returned directly from stripe
  #
  # REFERRAL CODE
  # referralCode: the code used for the referral
  # referralUser: the user who referred this customer, the owner of the referral code
  #   _id
  #   displayName
  #
  # STORE CREDIT
  # storeCreditAmount: USD value of store credit used
  @Meta
    name: @id()
    fields: =>
      paymentMethod: @ReferenceField RS.PaymentMethod, [], false
      referralUser: @ReferenceField RA.User, ['displayName'], false
      invalid: @GeneratedField 'self', ['chargeError'], (fields) ->
        invalid = false
        invalid = true if fields.chargeError
        [fields._id, invalid]
      
  @forCurrentUser: @subscription 'forCurrentUser'

  @Types:
    KickstarterPledge: 'KickstarterPledge'
    PatreonPledge: 'PatreonPledge'
    StripePayment: 'StripePayment'
    ReferralCode: 'ReferralCode'
    StoreCredit: 'StoreCredit'

  @Projects:
    PixelArtAcademy: 'PixelArtAcademy'
