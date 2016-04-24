LOI = LandsOfIllusions
PAA = PixelArtAcademy

Actor = LOI.Adventure.Actor
Action = LOI.Adventure.Actor.Abilities.Action
Talking = LOI.Adventure.Actor.Abilities.Talking

class PAA.Adventure.Locations.Studio extends LOI.Adventure.Location
  keyName: -> 'studio'
  displayName: -> "studio room"

  constructor: ->
    super

    jessie = new Actor
    jessie.displayName = 'Jessie'

    jessie.addAbility Talking
    jessie.addAbility Action,
      verb: "Talk"
      action: =>
        @director.startScript scene1

    corinne = new Actor
    corinne.displayName = 'Corinne'

    corinne.addAbility Talking
    corinne.addAbility Action,
      verb: "Ramble"
      action: =>
        @director.startScript scene2

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

    scene2 = LOI.Adventure.Script.create
      director: @director

      actors:
        jessie: jessie
        corinne: corinne

      script:
        """
          jessie: testing longer scripts, just in case
          jessie: we need something like this
          corinne: how much wood could a woodchuck chuck
          corinne: if a woodchuck could chuck wood
        """
