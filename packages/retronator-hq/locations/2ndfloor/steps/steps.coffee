LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action
Talking = LOI.Adventure.Ability.Talking

class HQ.Locations.Steps extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.Steps'
  @url: -> 'retronator/steps'
  @scriptUrls: -> [
    'retronator-hq/hq.script'
  ]

  @version: -> '0.0.1'

  @fullName: -> "Retronator HQ lounge steps"
  @shortName: -> "steps"
  @description: ->
    "
      The stairs that lead to the second floor are accompanied with bigger steps on the sides, perfect for sitting and
      lounging. Tetromino-shaped cushions are distributed for comfort and a few hipster kids are using them, glued
      tirelessly to their laptops. The stairs turn a corner in an L-shape to the south.
    "
  
  @initialize()

  constructor: ->
    super

  @state: ->
    things = {}

    exits = {}
    exits[Vocabulary.Keys.Directions.Down] = HQ.Locations.Lobby.id()
    exits[Vocabulary.Keys.Directions.East] = HQ.Locations.Lobby.id()
    exits[Vocabulary.Keys.Directions.Up] = HQ.Locations.Checkout.id()
    exits[Vocabulary.Keys.Directions.South] = HQ.Locations.Checkout.id()

    _.merge {}, super,
      things: things
      exits: exits
