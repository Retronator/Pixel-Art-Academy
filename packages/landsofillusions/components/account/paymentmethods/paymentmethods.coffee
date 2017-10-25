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

    RS.PaymentMethod.forCurrentUser.subscribe @

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
            RS.PaymentMethod.insertStripe token.id, token.email

        @stripeInitialized true
      ,
        100

    else
      console.warn "Set Stripe public and secret key in the settings file if you want to enable Stripe purchases."

  paymentMethods: ->
    RS.PaymentMethod.documents.find()

  moreThan2Class: ->
    'more-than-2' if @paymentMethods().count() > 2

  events: ->
    super.concat
      'click .add-stripe-button': @onClickAddStripeButton

  onClickAddStripeButton: (event) ->
    @_stripeCheckout.open()

  class @Stripe extends AM.Component
    @register 'LandsOfIllusions.Components.Account.PaymentMethods.Stripe'

    onCreated: ->
      super

      @customerData = new ReactiveField null
      @loading = new ReactiveField false

    openedClass: ->
      'opened' if @customerData()

    loadingClass: ->
      'loading' if @loading()

    events: ->
      super.concat
        'click .case': @onClickCase
        'click .remove-button': @onClickRemoveButton

    onClickCase: (event) ->
      # Clear data if we're already showing it.
      if @customerData()
        @customerData null
        return

      @loading true

      paymentMethod = @data()
      RS.PaymentMethod.getStripeCustomerData paymentMethod._id, (error, customerData) =>
        @loading false

        if error
          console.error error
          return

        @customerData customerData

    onClickRemoveButton: (event) ->
      paymentMethod = @data()

      dialog = new LOI.Components.Dialog
        message: "Do you really want to remove this payment method?"
        buttons: [
          text: "Yes"
          value: true
        ,
          text: "Cancel"
        ]

      LOI.adventure.showActivatableModalDialog
        dialog: dialog
        callback: =>
          return unless dialog.result

          RS.PaymentMethod.removeStripe paymentMethod._id
