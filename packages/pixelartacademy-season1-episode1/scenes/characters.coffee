LOI = LandsOfIllusions
PAA = PixelArtAcademy
E1 = PixelArtAcademy.Season1.Episode1
HQ = Retronator.HQ

class E1.Characters extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Characters'

  @location: ->
    # We are calculating the characters at the current location.
    LOI.adventure.currentLocationId()

  @initialize()

  constructor: ->
    super

  things: ->
    characters = []

    locationId = _.thingId @location()
    character = LOI.character()
    characterLocationId = LOI.adventure.gameState()?.currentLocationId

    # If the player's character is at this location, add it to the scene.
    characters.push character if locationId is characterLocationId

    characters
