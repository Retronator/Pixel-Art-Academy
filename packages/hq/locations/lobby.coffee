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
      SignInActive: (completeMethod) =>
        LOI.Adventure.activateItem Retronator.HQ.Items.Wallet
