LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Adventure.Parser.Vocabulary

Actor = LOI.Adventure.Actor
Action = LOI.Adventure.Actor.Abilities.Action
Talking = LOI.Adventure.Actor.Abilities.Talking

class HQ.Locations.Lobby extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.Lobby'
  @url: -> 'retronator/lobby'

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

    jessie = new Actor
      name: "Jessie"

    jessie.addAbility Action,
      verb: "talk"
      action: =>
        @director.startScript scene1

    corinne = new Actor
      name: "Corinne"

    @addActor jessie
    @addActor corinne

    scene1 = LOI.Adventure.Script.create
      director: @director
      actors:
        jessie: jessie
        corinne: corinne
      script:
        """
          jessie: Hey, how are you?
          corinne: Good, you?
          jessie: Doing great, what's up?
          corinne: Not much. Just heading to the store.
          corinne: Want to grab lunch afterwards?
          jessie: Sure thing dawg!
        """
