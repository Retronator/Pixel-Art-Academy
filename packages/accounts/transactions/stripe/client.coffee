Meteor.startup ->
  return unless Meteor.settings.public.stripe?.publishableKey

  stripeKey = Meteor.settings.public.stripe.publishableKey
  Stripe.setPublishableKey stripeKey
