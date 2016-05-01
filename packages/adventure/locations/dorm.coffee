LOI = LandsOfIllusions
PAA = PixelArtAcademy

Actor = LOI.Adventure.Actor
Action = LOI.Adventure.Actor.Abilities.Action
Talking = LOI.Adventure.Actor.Abilities.Talking

class PAA.Adventure.Locations.Dorm extends LOI.Adventure.Location
  keyName: -> 'dorm'
  displayName: -> "dorm room"

  constructor: ->
    super
    
    jessie = new Actor
    jessie.addAbility Talking
    jessie.addAbility Action,
      verb: "Talk"
      action: =>
        @director.startScript scene1

    corinne = new Actor
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
