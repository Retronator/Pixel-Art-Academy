RA = Retronator.Accounts

class RA.Patreon extends RA.Patreon
  @requestCredential = (options, credentialRequestCompleteCallback) ->
    if _.isFunction options and not credentialRequestCompleteCallback
      credentialRequestCompleteCallback = options
      options = {}

    config = ServiceConfiguration.configurations.findOne service: 'patreon'
  
    unless config
      error = new ServiceConfiguration.ConfigError

      credentialRequestCompleteCallback? error
      return error

    credentialToken = Random.secret()
    loginStyle = OAuth._loginStyle('patreon', config, options)
    state = OAuth._stateParam(loginStyle, credentialToken)

    redirectUrl = Meteor.absoluteUrl '_oauth/patreon?close'
    loginUrl = "https://www.patreon.com/oauth2/authorize?response_type=code&client_id=#{config.clientId}&state=#{state}&redirect_uri=#{redirectUrl}"

    OAuth.launchLogin
      loginService: 'patreon'
      loginStyle: loginStyle
      loginUrl: loginUrl
      credentialRequestCompleteCallback: credentialRequestCompleteCallback
      credentialToken: credentialToken
      popupOptions:
        height: 550

Meteor.loginWithPatreon = (options, callback) ->
  if _.isFunction(options) and not callback
    callback = options
    options = null

  credentialRequestCompleteCallback = Accounts.oauth.credentialRequestCompleteHandler callback

  RA.Patreon.requestCredential options, credentialRequestCompleteCallback

Meteor.linkWithPatreon = (options, callback) ->
  throw new AE.UnauthorizedException "Please login to an existing account before link." unless Meteor.userId()

  if _.isFunction options and not callback
    callback = options
    options = null

  credentialRequestCompleteCallback = Accounts.oauth.linkCredentialRequestCompleteHandler callback
  RA.Patreon.requestCredential options, credentialRequestCompleteCallback
