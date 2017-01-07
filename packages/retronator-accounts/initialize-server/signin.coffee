# OAuth encryption
if Meteor.settings.oauthSecretKey
  Accounts.config
    oauthSecretKey: Meteor.settings.oauthSecretKey

else
  console.warn "You need to specify oauthSecretKey in the settings file and don't forget to run the server with the --settings flag pointing to it."

# Facebook sign-in configuration
Meteor.startup ->
  unless Meteor.settings.facebook
    console.warn "You need to specify facebook app ID and secret in the settings file and don't forget to run the server with the --settings flag pointing to it."
    return

  ServiceConfiguration.configurations.upsert
    service: "facebook"
  ,
    $set:
      appId: Meteor.settings.facebook.appId,
      secret: Meteor.settings.facebook.secret

# Twitter sign-in configuration
Meteor.startup ->
  unless Meteor.settings.twitter
    console.warn "You need to specify twitter consumer key and secret in the settings file and don't forget to run the server with the --settings flag pointing to it."
    return

  ServiceConfiguration.configurations.upsert
    service: "twitter"
  ,
    $set:
      consumerKey: Meteor.settings.twitter.consumerKey,
      secret: Meteor.settings.twitter.secret

# Google sign-in configuration
Meteor.startup ->
  unless Meteor.settings.google
    console.warn "You need to specify google client id and secret in the settings file and don't forget to run the server with the --settings flag pointing to it."
    return

  ServiceConfiguration.configurations.upsert
    service: "google"
  ,
    $set:
      clientId: Meteor.settings.google.clientId,
      secret: Meteor.settings.google.secret
