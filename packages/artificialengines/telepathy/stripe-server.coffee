AE = Artificial.Everywhere
AT = Artificial.Telepathy
StripeAPI = Npm.require 'stripe'

# Stripe API wrapper.
class AT.Stripe
  if Meteor.settings.stripe?.secretKey
    @_stripe = StripeAPI Meteor.settings.stripe.secretKey

    @_api =
      customers:
        create: Meteor.wrapAsync @_stripe.customers.create.bind @_stripe.customers
        retrieve: Meteor.wrapAsync @_stripe.customers.retrieve.bind @_stripe.customers
        del: Meteor.wrapAsync @_stripe.customers.del.bind @_stripe.customers
      charges:
        create: Meteor.wrapAsync @_stripe.charges.create.bind @_stripe.charges
        retrieve: Meteor.wrapAsync @_stripe.charges.retrieve.bind @_stripe.charges

    @initialized = true

  @customers:
    # We need to use AT.Stripe, because @ refers to this intermediary object created by doing another level.
    create: -> AT.Stripe._call AT.Stripe._api.customers.create, arguments...
    retrieve: -> AT.Stripe._call AT.Stripe._api.customers.retrieve, arguments...
    delete: -> AT.Stripe._call AT.Stripe._api.customers.del, arguments...

  @charges:
    # We need to use AT.Stripe, because @ refers to this intermediary object created by doing another level.
    create: -> AT.Stripe._call AT.Stripe._api.charges.create, arguments...
    retrieve: -> AT.Stripe._call AT.Stripe._api.charges.retrieve, arguments...

  @_call: (method, params, callback) ->
    try
      if callback
        method params, (error, result) =>
          if error
            @_handleError error
            return

          callback result

      else
        result = method params

        unless result
          console.log "Error accessing Stripe API."
          return

        result

    catch error
      @_handleError error

  @_handleError: (error) ->
    switch error.code
      when 429
        throw new AE.LimitExceededException "Too many requests to Stripe API."

      else
        throw error
