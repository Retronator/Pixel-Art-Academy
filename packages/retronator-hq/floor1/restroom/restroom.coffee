LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class HQ.Restroom extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Restroom'
  @url: -> 'retronator/restroom'

  @version: -> '0.0.1'

  @fullName: -> "1st floor restroom"
  @shortName: -> "restroom"
  @description: ->
    "
      You're inside a small single-stall restroom. It's pretty much what you'd expect from a restroom and you don't have
      much use for it within a video game.
    "
  
  @initialize()

  constructor: ->
    super

  exits: ->
    "#{Vocabulary.Keys.Directions.South}": HQ.Passage
