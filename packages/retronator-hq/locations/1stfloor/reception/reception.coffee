LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class HQ.Locations.Reception extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.Reception'
  @url: -> 'retronator/reception'
  @scriptUrls: -> [
    'retronator-hq/hq.script'
    'retronator-hq/locations/1stfloor/reception/burra.script'
    'retronator-hq/actors/elevatorbutton.script'
  ]

  @version: -> '0.0.1'

  @fullName: -> "Retronator HQ reception"
  @shortName: -> "reception"
  @description: ->
    "
      You are at a long counter at the south side of the lobby. The receptionist is working on
      something very important.
    "
  
  @initialize()

  constructor: ->
    super

    @loginButtonsSession = Accounts._loginButtonsSession

  @state: ->
    things = {}
    things[PAA.Cast.Burra.id()] =
      displayOrder: 0
      inventory: {}

    exits = {}
    exits[Vocabulary.Keys.Directions.North] = HQ.Locations.Lobby.id()
    exits[Vocabulary.Keys.Directions.West] = HQ.Locations.Gallery.id()

    _.merge {}, super,
      things: things
      exits: exits

  onScriptsLoaded: ->
    # Burra
    Tracker.autorun (computation) =>
      return unless burra = @things PAA.Cast.Burra.id()
      computation.stop()

      burra.addAbility new Action
        verb: Vocabulary.Keys.Verbs.Talk
        action: =>
          LOI.adventure.director.startScript dialog

      @useWallet = =>
        LOI.adventure.director.startScript dialog, label: 'UseWallet'

      dialog = @scripts['Retronator.HQ.Locations.Reception.Scripts.Burra']
  
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
