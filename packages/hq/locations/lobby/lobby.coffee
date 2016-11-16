LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Adventure.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action
Talking = LOI.Adventure.Ability.Talking

class HQ.Locations.Lobby extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.Lobby'
  @url: -> 'retronator/lobby'
  @scriptUrls: -> [
    'retronator_hq/locations/lobby/retro.script'
    'retronator_hq/actors/elevatorbutton.script'
  ]

  @fullName: -> "Retronator HQ lobby"
  @shortName: -> "lobby"
  @description: ->
    "
      You are in a comfortable lobby like hall. It is the entry level of Retronator HQ. The receptionist is working on
      something very important. There is a big screen on the back wall displaying all supporters of Retronator.
    "
  
  @initialize()

  constructor: ->
    super

    @loginButtonsSession = Accounts._loginButtonsSession
    
    HQ.Locations.Elevator.setupElevatorExit
      location: @
      floor: 1

  initialState: ->
    things = {}
    things[PAA.Cast.Retro.id()] = displayOrder: 0
    things[HQ.Locations.Lobby.Display.id()] = displayOrder: 1
    things[HQ.Actors.ElevatorButton.id()] = displayOrder: 2

    exits = {}

    _.merge {}, super,
      things: things
      exits: exits

  onScriptsLoaded: ->
    # Retro
    Tracker.autorun (computation) =>
      return unless retro = @things PAA.Cast.Retro.id()
      computation.stop()

      retro.addAbility new Action
        verb: Vocabulary.Keys.Verbs.Talk
        action: =>
          @director().startScript retroDialog

      retroDialog = @scripts['Retronator.HQ.Locations.Lobby.Scripts.Retro']
  
      retroDialog.setActors
        retro: retro

      retroDialog.setCallbacks
        SignInActive: (complete) =>
          LOI.Adventure.goToItem Retronator.HQ.Items.Wallet
  
          # Wait until wallet has been active and deactivated again.
          walletActive = false
  
          Tracker.autorun (computation) =>
            activeItem = @options.adventure.activeItem()
  
            if activeItem and not walletActive
              walletActive = true
  
            else if not activeItem and walletActive
              computation.stop()
  
              console.log "Wallet has deactivated. The user ID is now", Meteor.userId(), "The subscription for the game state is", @options.adventure.gameStateSubsription if LOI.debug
  
              # If user has signed in, wait also until the game state has been loaded.
              Tracker.autorun (computation) =>
                return if Meteor.userId() and not @options.adventure.gameStateSubsription.ready()
                computation.stop()
  
                complete()
  
        ReceiveAccountFile: (complete) =>
          console.log "receiving account file", @options.adventure.gameState().player.inventory
          @options.adventure.gameState().player.inventory[HQ.Items.AccountFile.id()] = {}
          @options.adventure.gameState.updated()
          complete()
  
        CreateNewAccount: (complete) =>
          # Insert the current local storage state as the start of the database one.
          LOI.GameState.insertForCurrentUser @options.adventure.gameState(), =>
            complete()
  
        ReturnAccountFile: (complete) =>
          delete @options.adventure.gameState().player.inventory[HQ.Items.AccountFile.id()]
          @options.adventure.gameState.updated()
          complete()
  
        SignOut: (complete) =>
          @options.adventure.logout()
          complete()
  
        OpenRetronatorMagazine: (complete) =>
  
        GiveProspectus: (complete) =>

    # Elevator button
    HQ.Actors.ElevatorButton.setupButton 
      location: @
      floor: 1
