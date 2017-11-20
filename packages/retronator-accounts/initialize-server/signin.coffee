# OAuth encryption
if Meteor.settings.oauthSecretKey
  Accounts.config
    oauthSecretKey: Meteor.settings.oauthSecretKey

else
  console.warn "Set oauthSecretKey in the settings file if you want sensitive login services data to be encrypted."

# Facebook sign-in configuration
Meteor.startup ->
  return unless Meteor.settings.facebook
  return if Meteor.settings.startEmpty

  ServiceConfiguration.configurations.upsert
    service: "facebook"
  ,
    $set:
      appId: Meteor.settings.facebook.appId,
      secret: Meteor.settings.facebook.secret

# Twitter sign-in configuration
Meteor.startup ->
  return unless Meteor.settings.twitter
  return if Meteor.settings.startEmpty

  ServiceConfiguration.configurations.upsert
    service: "twitter"
  ,
    $set:
      consumerKey: Meteor.settings.twitter.consumerKey,
      secret: Meteor.settings.twitter.secret

# Google sign-in configuration
Meteor.startup ->
  return unless Meteor.settings.google
  return if Meteor.settings.startEmpty

  ServiceConfiguration.configurations.upsert
    service: "google"
  ,
    $set:
      clientId: Meteor.settings.google.clientId,
      secret: Meteor.settings.google.secret

# Patreon sign-in configuration
Meteor.startup ->
  return unless Meteor.settings.patreon
  return if Meteor.settings.startEmpty

  ServiceConfiguration.configurations.upsert
    service: "patreon"
  ,
    $set:
      clientId: Meteor.settings.patreon.clientId,
      clientSecret: Meteor.settings.patreon.clientSecret
