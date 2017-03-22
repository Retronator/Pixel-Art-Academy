LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class HQ.Restroom extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Restroom'
  @url: -> 'retronator/restroom'
  @scriptUrls: -> [
    'retronator-hq/hq.script'
  ]

  @version: -> '0.0.1'

  @fullName: -> "Retronator HQ restroom"
  @shortName: -> "restroom"
  @description: ->
    "
      You're inside a small private restroom. It's pretty much what you'd expect from a restroom and you don't have
      much use for it within a video game.
    "
  
  @initialize()

  constructor: ->
    super

  @state: ->
    things = {}

    exits = {}
    exits[Vocabulary.Keys.Directions.South] = HQ.Gallery.id()

    _.merge {}, super,
      things: things
      exits: exits
