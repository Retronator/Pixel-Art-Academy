LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Adventure.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action
Talking = LOI.Adventure.Ability.Talking

class HQ.Locations.Reception extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.Reception'
  @url: -> 'retronator/reception'
  @scriptUrls: -> [
    'retronator_hq/hq.script'
    'retronator_hq/locations/1stfloor/reception/burra.script'
    'retronator_hq/actors/elevatorbutton.script'
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
          @director().startScript dialog

      @useWallet = =>
        @director().startScript dialog, label: 'UseWallet'

      dialog = @scripts['Retronator.HQ.Locations.Reception.Scripts.Burra']
  
      dialog.setActors
        burra: burra

      dialog.setCallbacks
        SignInActive: (complete) =>
          @options.adventure.scriptHelpers.itemInteraction
            item: Retronator.HQ.Items.Wallet
            callback: =>
              console.log "Wallet has deactivated. The user ID is now", Meteor.userId(), "The subscription for the game state is", @options.adventure.gameStateSubsription if LOI.debug
  
              Tracker.autorun (computation) =>
                # If user has signed in, wait also until the game state has been loaded.
                return if Meteor.userId() and not @options.adventure.gameStateSubsription.ready()
                computation.stop()
  
                complete()

        CreateNewAccount: (complete) =>
          # Insert the current local storage state as the start of the database one.
          LOI.GameState.insertForCurrentUser @options.adventure.gameState(), =>
            complete()

            # Now that the local state has been transferred, clear it for next player.
            @options.adventure.clearLocalGameState()

        ReceiveTablet: (complete) =>
          @options.adventure.scriptHelpers.receiveItemFromActor
            location: @
            actor: PAA.Cast.Burra
            item: HQ.Items.Tablet

          complete()

        ReturnTablet: (complete) =>
          @options.adventure.scriptHelpers.giveItemToActor
            location: @
            actor: PAA.Cast.Burra
            item: HQ.Items.Tablet

          complete()

        ReceiveAccountApp: (complete) =>
          tablet = @options.adventure.inventory HQ.Items.Tablet.id()
          tablet.addApp HQ.Items.Tablet.Apps.Account
          complete()

        SignOut: (complete) =>
          @options.adventure.logout()
          complete()
  
        OpenRetronatorMagazine: (complete) =>
          medium = window.open 'https://medium.com/retronator-magazine', '_blank'
          medium.focus()

          # Wait for our window to get focus.
          $(window).on 'focus.medium', =>
            complete()
            $(window).off '.medium'

        ReceiveProspectusApp: (complete) =>
          tablet = @options.adventure.inventory HQ.Items.Tablet.id()
          tablet.addApp HQ.Items.Tablet.Apps.Prospectus
          complete()

    # Elevator button
    HQ.Actors.ElevatorButton.setupButton 
      location: @
      floor: 1
