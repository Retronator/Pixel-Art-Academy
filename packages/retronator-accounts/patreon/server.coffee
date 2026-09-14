AE = Artificial.Everywhere
AT = Artificial.Telepathy
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
    clientSecret = OAuth.openSecret config.secret
    redirectUri = OAuth._redirectUri 'patreon', config

    tokenResponseData = AT.Patreon.exchangeAuthorizationCode query.code, config.clientId, clientSecret, redirectUri
    throw new Error "Patreon returned no access token." unless tokenResponseData?.access_token
    accessToken = tokenResponseData.access_token

  catch error
    console.error error
    console.error "Patreon OAuth redirect URI: #{redirectUri}" if redirectUri
    throw new AE.InvalidOperationException "Failed to complete OAuth handshake with Patreon."

  if tokenResponseData.error
    console.error tokenResponseData.error
    throw new AE.InvalidOperationException "Failed to complete OAuth handshake with Patreon.", tokenResponseData.error

  try
    currentUserResponse = HTTP.get 'https://www.patreon.com/api/oauth2/v2/identity',
      headers:
        Authorization: "Bearer #{accessToken}"
        'User-Agent': AT.Patreon.userAgent
      params:
        'fields[user]': 'email'

    userProfile = AT.Patreon._parseResponseData(currentUserResponse)?.data
    throw new Error "Patreon returned no user profile." unless userProfile

    # Update user's Patreon pledge.
    RA.Patreon.updateCurrentPledgeForPatron userProfile.id

  catch error
    console.error error
    throw new AE.InvalidOperationException "Failed to fetch account data from Patreon.", error.message

  serviceData: _.extend
    accessToken: accessToken
    refreshToken: tokenResponseData.refresh_token
    expiresAt: Date.now() + 1000 * tokenResponseData.expires_in
    # We add the email fields for accounts-emails-field and accounts-meld to work.
    email: userProfile.attributes.email
  ,
    userProfile
