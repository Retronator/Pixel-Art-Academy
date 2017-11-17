AE = Artificial.Everywhere
RA = Retronator.Accounts

class RA.Patreon extends RA.Patreon
  @retrieveCredential: (credentialToken, credentialSecret) ->
    OAuth.retrieveCredential credentialToken, credentialSecret

Accounts.addAutopublishFields
  forLoggedInUser: [
    'services.patreon.accessToken'
    'services.patreon.expiresAt'
  ],
  forOtherUsers: []

OAuth.registerService 'patreon', 2, null, (query) ->
  config = ServiceConfiguration.configurations.findOne service: 'patreon'
  throw new ServiceConfiguration.ConfigError unless config

  try
    tokenResponse = HTTP.post 'https://www.patreon.com/api/oauth2/token', params:
      code: query.code
      client_id: config.clientId
      client_secret: OAuth.openSecret(config.clientSecret)
      grant_type: 'authorization_code'
      redirect_uri: Meteor.absoluteUrl '_oauth/patreon?close'

    accessToken = tokenResponse.data.access_token

  catch error
    console.error error
    throw new AE.InvalidOperationException "Failed to complete OAuth handshake with Patreon."

  if tokenResponse.data.error
    console.error tokenResponse.data.error
    throw new AE.InvalidOperationException "Failed to complete OAuth handshake with Patreon.", tokenResponse.data.error

  try
    currentUserResponse = HTTP.get 'https://www.patreon.com/api/oauth2/api/current_user',
      headers:
        Authorization: "Bearer #{accessToken}"

    content = JSON.parse currentUserResponse.content
    userProfile = content.data

  catch error
    console.error error
    throw new AE.InvalidOperationException "Failed to fetch account data from Patreon.", error.message

  serviceData: _.extend
    accessToken: accessToken
    refreshToken: tokenResponse.data.refresh_token
    expiresAt: Date.now() + 1000 * tokenResponse.data.expires_in
    # We add the email fields for accounts-emails-field and accounts-meld to work.
    email: userProfile.attributes.email
  ,
    userProfile
