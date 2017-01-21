AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts

class LOI.Components.Account.Services extends LOI.Components.Account.Page
  @register 'LandsOfIllusions.Components.Account.Services'
  @url: -> 'services'
  @displayName: -> 'Sign-in services'

  @initialize()

  onCreated: ->
    super

    @subscribe Retronator.Accounts.User.loginServicesForCurrentUser

  loginServices: ->
    [
      'Password'
      'Facebook'
      'Twitter'
      'Google'
    ]

  loginServiceEnabled: ->
    serviceName = @currentData()
    user = Meteor.user()

    return unless user?.loginServices?

    _.lowerCase(serviceName) in user.loginServices

  stampUrl: ->
    serviceName = @currentData()

    "/landsofillusions/components/account/services/#{_.lowerCase serviceName}.png"

  # Events

  events: ->
    super.concat
      'click .link-service-button': @onClickLinkService

  onClickLinkService: (event) ->
    serviceName = @currentData()
    
    if serviceName is 'Password'
      Meteor.call RA.User.sendPasswordResetEmail, (error) ->
        if error
          console.error error.message
          return
      
    else
      Meteor["linkWith#{serviceName}"]()
