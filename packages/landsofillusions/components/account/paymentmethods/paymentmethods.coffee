AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

class LOI.Components.Account.PaymentMethods extends LOI.Components.Account.Page
  @register 'LandsOfIllusions.Components.Account.PaymentMethods'
  @url: -> 'payment-methods'
  @displayName: -> 'Payment methods'

  @initialize()

  onCreated: ->
    super

    @stripeInitialized = new ReactiveField false
    @stripeEnabled = false

  onRendered: ->
    super

    if Meteor.settings.public.stripe?.publishableKey
      @stripeEnabled = true

      initializeStripeInterval = Meteor.setInterval =>
        # Wait until checkout is ready.
        return unless StripeCheckout?

        Meteor.clearInterval initializeStripeInterval

        @_stripeCheckout = StripeCheckout.configure
          key: Meteor.settings.public.stripe.publishableKey
          image: 'https://stripe.com/img/documentation/checkout/marketplace.png'
          name: 'Retronator'
          panelLabel: 'Add card'
          locale: 'auto'
          token: (token) =>
            RS.PaymentMethod.addStripe token.id, token.email

        @stripeInitialized true
      ,
        100

    else
      console.warn "Set Stripe public and secret key in the settings file if you want to enable Stripe purchases."

  events: ->
    super.concat
      'click .add-stripe-button': @onClickAddStripeButton

  onClickAddStripeButton: (event) ->
    @_stripeCheckout.open()
