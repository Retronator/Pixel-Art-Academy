LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Adventure.Parser.Vocabulary

Actor = LOI.Adventure.Actor
Action = LOI.Adventure.Actor.Abilities.Action
Talking = LOI.Adventure.Actor.Abilities.Talking

class HQ.Locations.Lobby.Elevator extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.Lobby.Elevator'
  @url: -> 'retronator/lobby/elevator'
  @scriptUrls: -> [
    'retronator_hq/locations/lobby-elevator-pad.script'
  ]

  @fullName: -> "Lobby floor elevator"
  @shortName: -> "elevator"
  @description: ->
    "
      You are in the elevator on the lobby floor of Retronator HQ. The number pad on the side lets you travel to other
      floors.
    "

  @initialize()

  constructor: ->
    super

    @addExit Vocabulary.Keys.Directions.Out, HQ.Locations.Lobby.id()
  
  onScriptsLoaded: ->
    pad = @addActor new HQ.Actors.ElevatorNumberPad

    pad.addAbility Action,
      verb: Vocabulary.Keys.Verbs.Use
      action: =>
        @director.startScript padInteraction

    padInteraction = @scripts['Retronator.HQ.Locations.Lobby.Elevator.Scripts.NumberPad']

    padInteraction.setActors
      pad: pad

    padInteraction.setCallbacks
      Store: (complete) =>
        LOI.Adventure.goToLocation HQ.Locations.Store.Elevator.id()
        complete()

      LOI: (complete) =>
        LOI.Adventure.goToLocation HQ.Locations.Store.Elevator.id()
        complete()

      IdeaGarden: (complete) =>
        LOI.Adventure.goToLocation HQ.Locations.Store.Elevator.id()
        complete()
