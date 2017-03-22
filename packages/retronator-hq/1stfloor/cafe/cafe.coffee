LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class HQ.Cafe extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Cafe'
  @url: -> 'retronator/reception'

  @version: -> '0.0.1'

  @fullName: -> "Retronator HQ café"
  @shortName: -> "café"
  @description: ->
    "
      The cosy café has plenty of tables and you recognize some familiar faces from the Pixel Art Academy Facebook
      group. The north wall displays a selection of artworks from the current featured pixel artist. In the south
      there is a self-serve bar and Burra's carefully decorated workstation. A passageway connects to the coworking space
      in the west, and there are big steps with stairs heading up towards the store.
    "
  
  @initialize()

  constructor: ->
    super

    @loginButtonsSession = Accounts._loginButtonsSession

  things: -> [
    @constructor.Artworks
    PAA.Cast.Burra
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.Out}": SanFrancisco.Soma.SecondStreet

  class @BurraListener extends LOI.Adventure.Listener
    @id: -> "Retronator.HQ.Cafe.Burra"

    @scriptUrls: -> [
      'retronator_retronator-hq/1stfloor/cafe/burra.script'
    ]

    class @Script extends LOI.Adventure.Script
      @id: -> "Retronator.HQ.Cafe.Burra"
      @initialize()

    @initialize()

    startScript: (options) ->
      LOI.adventure.director.startScript @script, options

    onScriptsLoaded: ->
      @script = @scripts[@id()]

    onCommand: (commandResponse) ->
      return unless burra = LOI.adventure.getCurrentThing PAA.Cast.Burra
      @script.setThings {burra}

      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.TalkTo, burra.avatar]
        action: => LOI.adventure.director.startScript @script

    onEnter: (enterResponse) ->

    onExitAttempt: (exitResponse) ->
      
    onExit: (exitResponse) ->
      
    cleanup: ->

  onScriptsLoaded: ->
    # Burra
    Tracker.autorun (computation) =>
      return unless burra = @things PAA.Cast.Burra.id()
      computation.stop()

      burra.addAbility new Action
        verb: Vocabulary.Keys.Verbs.TalkTo
        action: =>
          LOI.adventure.director.startScript dialog

      @useWallet = =>
        LOI.adventure.director.startScript dialog, label: 'UseWallet'

      dialog = @scripts['Retronator.HQ.Cafe.Scripts.Burra']
  
      dialog.setThings
        burra: burra

      dialog.setCallbacks
        SignInActive: (complete) =>
          LOI.adventure.scriptHelpers.itemInteraction
            item: Retronator.HQ.Items.Wallet
            callback: =>
              console.log "Wallet has deactivated. The user ID is now", Meteor.userId(), "The subscription for the game state is", LOI.adventure.gameStateSubsription if LOI.debug
  
              Tracker.autorun (computation) =>
                # If user has signed in, wait also until the game state has been loaded.
                return if Meteor.userId() and not LOI.adventure.gameStateSubsription.ready()
                computation.stop()
  
                complete()

        CreateNewAccount: (complete) =>
          # Insert the current local storage state as the start of the database one.
          LOI.GameState.insertForCurrentUser LOI.adventure.gameState(), =>
            complete()

            # Now that the local state has been transferred, clear it for next player.
            LOI.adventure.clearLocalGameState()

        ReceiveTablet: (complete) =>
          LOI.adventure.scriptHelpers.receiveItemFromActor
            location: @
            actor: PAA.Cast.Burra
            item: HQ.Items.Tablet

          complete()

        ReturnTablet: (complete) =>
          LOI.adventure.scriptHelpers.giveItemToActor
            location: @
            actor: PAA.Cast.Burra
            item: HQ.Items.Tablet

          complete()

        ReceiveAccountApp: (complete) =>
          tablet = LOI.adventure.inventory HQ.Items.Tablet.id()
          tablet.addApp HQ.Items.Tablet.Apps.Account
          complete()

        SignOut: (complete) =>
          LOI.adventure.logout()
          complete()
  
        OpenRetronatorMagazine: (complete) =>
          medium = window.open 'https://medium.com/retronator-magazine', '_blank'
          medium.focus()

          # Wait for our window to get focus.
          $(window).on 'focus.medium', =>
            complete()
            $(window).off '.medium'

        ReceiveProspectusApp: (complete) =>
          tablet = LOI.adventure.inventory HQ.Items.Tablet.id()
          tablet.addApp HQ.Items.Tablet.Apps.Prospectus
          complete()

    # Elevator button
    HQ.Actors.ElevatorButton.setupButton
      location: @
      floor: 1
