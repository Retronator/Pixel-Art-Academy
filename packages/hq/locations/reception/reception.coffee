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
    'retronator_hq/locations/reception/burra.script'
    'retronator_hq/actors/elevatorbutton.script'
  ]

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

  initialState: ->
    things = {}
    things[PAA.Cast.Burra.id()] = displayOrder: 0

    exits = {}
    exits[Vocabulary.Keys.Directions.North] = HQ.Locations.Lobby.id()

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
          @director().startScript retroDialog

      retroDialog = @scripts['Retronator.HQ.Locations.Reception.Scripts.Burra']
  
      retroDialog.setActors
        burra: burra

      retroDialog.setCallbacks
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
  
        ReceiveAccountFile: (complete) =>
          @options.adventure.scriptHelpers.addItemToInventory item: HQ.Items.AccountFile
          complete()
  
        CreateNewAccount: (complete) =>
          # Insert the current local storage state as the start of the database one.
          LOI.GameState.insertForCurrentUser @options.adventure.gameState(), =>
            complete()
  
        ReturnAccountFile: (complete) =>
          @options.adventure.scriptHelpers.removeItemFromInventory item: HQ.Items.AccountFile
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
