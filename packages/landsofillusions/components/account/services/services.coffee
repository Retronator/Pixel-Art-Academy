AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts

class LOI.Components.Account.Services extends LOI.Components.Account.Page
  @register 'LandsOfIllusions.Components.Account.Services'
  @url: -> 'services'
  @displayName: -> 'Linked services'

  @initialize()

  onCreated: ->
    super arguments...

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
    super(arguments...).concat
      'click .link-service-button': @onClickLinkService
      'click .stamp': @onClickStamp

  onClickLinkService: (event) ->
    serviceName = @currentData()
    
    switch serviceName
      when 'Password'
        Meteor.call RA.User.sendPasswordResetEmail, (error) ->
          if error
            LOI.adventure.showDialogMessage error.message
            return
            
      else
        Meteor["linkWith#{serviceName}"]()

  onClickStamp: (event) ->
    serviceName = @currentData()
    loginServices = @loginServices()

    if serviceName is 'Password'
      message = "Do you want to change your password? A password reset email will be sent to you in that case."

      buttons = [
        text: "Change"
        value: true
      ,
        text: "Cancel"
      ]

    else if serviceName in loginServices
      # Make sure the user doesn't have just one login service (so we don't allow removing it).
      user = Meteor.user()

      if user.loginServices.length <= 1
        message = "This is your only way to sign in to your account. If you want to
                   remove this service, please add another way to sign in first."

        buttons = [text: "OK"]

      else
        message = "Do you want to remove this service? You will not be able
                   to use this service to sign into this account anymore."

        buttons = [
          text: "Remove"
          value: true
        ,
          text: "Cancel"
        ]

    else if serviceName is 'Patreon'
      message = """Do you want to remove the link to your Patreon membership? The rewards from you Patreon tier will
                   be removed, unless you also have your Patreon email added and confirmed on the Registration page."""

      moreInfo = """If you recently changed your pledge and you do not see your tier applied on the Purchases page,
                    we might not have updated our data yet. Click on the Refresh button to update now."""

      buttons = [
        text: "Remove"
        value: true
      ,
        text: "Refresh"
        value: 'refresh'
      ,
        text: "Cancel"
      ]

    dialog = new LOI.Components.Dialog {message, moreInfo, buttons}

    LOI.adventure.showActivatableModalDialog
      dialog: dialog
      callback: =>
        if dialog.result is true
          if serviceName is 'Password'
            Meteor.call RA.User.sendPasswordResetEmail, (error) ->
              if error
                LOI.adventure.showDialogMessage error.message
                return

          else
            RA.User.unlinkService serviceName, (error) ->
              if error
                LOI.adventure.showDialogMessage error.message
                return

        else if dialog.result is 'refresh'
          RA.Patreon.updateCurrentPledge (error) ->
            if error
              LOI.adventure.showDialogMessage error.message
              return

          LOI.adventure.showDialogMessage """Pledge update might take a minute to complete.
            If any changes are detected, you will see an update on the Purchases page."""
