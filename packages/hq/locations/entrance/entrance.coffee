LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Adventure.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action
Talking = LOI.Adventure.Ability.Talking

class HQ.Locations.Entrance extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.Entrance'
  @url: -> 'retronator/entrance'
  @scriptUrls: -> [
  ]

  @fullName: -> "Retronator HQ entrance"
  @shortName: -> "entrance"
  @description: ->
    "
      You're on the streets of San Francisco. To the west is the lobby of Retronator HQ. Possibilities are endless,
      yet there is nowhere to go but _IN_. You might want to _READ SIGN_ if you're new to all of this.
    "
  
  @initialize()

  constructor: ->
    super

  initialState: ->
    things = {}
    things[HQ.Locations.Entrance.Sign.id()] = displayOrder: 1

    exits = {}
    exits[Vocabulary.Keys.Directions.West] = HQ.Locations.Lobby.id()
    exits[Vocabulary.Keys.Directions.In] = HQ.Locations.Lobby.id()

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

      retroDialog = @scripts['Retronator.HQ.Locations.Lobby.Scripts.Burra']
  
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
