LOI = LandsOfIllusions
HQ = Retronator.HQ

Actor = LOI.Adventure.Actor
Action = LOI.Adventure.Actor.Abilities.Action
Talking = LOI.Adventure.Actor.Abilities.Talking

class HQ.Locations.Lobby extends LOI.Adventure.Location
  @setUrl 'retronator/lobby'

  constructor: ->
    super

    narrator = new Actor
      name: "Narrator"

    narrator.addAbility Talking

    @addActor narrator

    intro = LOI.Adventure.Script.create
      director: @director
      actors:
        narrator: narrator
      script:
        """
          narrator: You enter Retronator lobby and smell the creativity in the air.
        """

    @director.startScript intro

    jessie = new Actor
      name: "Jessie"

    jessie.addAbility Talking
    jessie.addAbility Action,
      verb: "talk"
      action: =>
        @director.startScript scene1

    corinne = new Actor
      name: "Corinne"

    corinne.addAbility Talking

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
