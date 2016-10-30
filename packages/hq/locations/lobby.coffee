LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Adventure.Parser.Vocabulary

Actor = LOI.Adventure.Actor
Action = LOI.Adventure.Actor.Abilities.Action
Talking = LOI.Adventure.Actor.Abilities.Talking

class HQ.Locations.Lobby extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.Lobby'
  @url: -> 'retronator/lobby'
  @scriptUrls: -> [
    'retronator_hq/locations/lobby-retro.script'
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

    @addExit Vocabulary.Keys.Directions.In, HQ.Locations.Lobby.Elevator.id()

    @loginButtonsSession = Accounts._loginButtonsSession

  onScriptsLoaded: ->
    retro = @addActor new PAA.Cast.Retro

    retro.addAbility Action,
      verb: Vocabulary.Keys.Verbs.Talk
      action: =>
        @director.startScript dialogTree

    dialogTree = @scripts['Retronator.HQ.Locations.Lobby.Scripts.Retro']

    dialogTree.setActors
      retro: retro

    dialogTree.setCallbacks
      SignInActive: (complete) =>
        LOI.Adventure.activateItem Retronator.HQ.Items.Wallet

        # Wait until wallet has been active and deactivated again.
        walletActive = false

        @autorun (computation) =>
          activeItem = @options.adventure.activeItem()

          if activeItem and not walletActive
            walletActive = true

          else if not activeItem and walletActive
            computation.stop()
            complete()

      SignOut: (complete) =>
        Meteor.logout()
        complete()

      ReceiveAccountFile: (complete) =>
        @options.adventure.inventory.addItem new HQ.Items.AccountFile adventure: @options.adventure
        complete()

      ReturnAccountFile: (complete) =>
        accountFile = @options.adventure.inventory[HQ.Items.AccountFile.id()]
        @options.adventure.inventory.removeItem accountFile
        complete()
