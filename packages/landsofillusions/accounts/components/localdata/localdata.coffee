AM = Artificial.Mirage
LOI = LandsOfIllusions

# The singleton component that communicates to the accounts client.
class LOI.Accounts.Components.LocalData extends AM.Component
  @register 'LandsOfIllusions.Accounts.Components.LocalData'

  @instance: new ReactiveField null

  constructor: ->
    super

    @debug = false

    # Store the singleton instance.
    @constructor.instance @

  onCreated: ->
    super

    # Listen for the returned login token result.
    $(window).on 'message.login-component', (event) =>
      data = event.originalEvent.data
      console.log "I GOT A MESSAGE BACK", data if @debug

      switch data.message
        when 'user data'
          if data.loginToken and data.loginTokenExpires and data.userId
            # Don't re-login (we require an explicit logout to prevent loggingIn state to happen here).
            return if Meteor.userId()

            # Login the user.
            console.log "LOGGIN IN WITH TOKEN", data.loginToken if @debug
            Meteor.loginWithToken data.loginToken

            unless data.characterId is undefined
              # Switch to the character.
              LOI.Accounts.switchCharacter data.characterId

          else
            Meteor.logout()
            LOI.Accounts.switchCharacter null

  onRendered: ->
    super

    localDataPage = "#{Meteor.settings.public.landsOfIllusionsUrl}/localdata"

    # Create an iFrame that will connect to the page which will pass us the login token for the user accounts system.
    @_$localDataIFrame = $('<iframe>').attr('src', localDataPage)
    @_$localDataIFrame.load ->
      # Send a message to the iFrame.
      console.log "SENDING A LOCAL DATA REQUEST to iframe.",  _.urlOrigin localDataPage if @debug
      @contentWindow.postMessage message: 'local data request', _.urlOrigin localDataPage

    @$('.loi-accounts-local-data').append(@_$localDataIFrame)

  # Report character switch back to the accounts client.
  switchCharacter: (characterId) ->
    localDataPage = "#{Meteor.settings.public.landsOfIllusionsUrl}/localdata"

    # TODO: Don't just discard the switch request if we aren't rendered. Store it temporarily to dispatch when we can.
    @_$localDataIFrame?[0].contentWindow.postMessage
      message: 'character switch'
      characterId: characterId

    , _.urlOrigin localDataPage
