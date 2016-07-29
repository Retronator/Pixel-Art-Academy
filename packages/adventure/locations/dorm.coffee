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

    dormroom = new Actor
    dormroom.displayName = 'DormRoom'
    dormroom.sprite = '/assets/adventure/dormroom.png'
    @addActor dormroom
