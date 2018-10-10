LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Residence.Bedroom extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Residence.Bedroom'
  @url: -> 'retronator/residence/bedroom'
  @scriptUrls: -> [
    'retronator_hq/hq.script'
  ]

  @version: -> '0.0.1'

  @fullName: -> "Retro's bedroom"
  @shortName: -> "bedroom"
  @description: ->
    "
      You peak through the doors and see a minimal bedroom with a queen bed and a closet.
      What catches your eye is that the ceiling is made of glass and opens up to the sky.
      You realize you're in Retro's bedroom and should probably leave back to the studio.
    "

  @initialize()

  constructor: ->
    super

  @state: ->
    things = {}

    exits = {}
    exits[Vocabulary.Keys.Directions.North] = HQ.Residence.Hallway.id()
    exits[Vocabulary.Keys.Directions.Out] = HQ.Residence.Hallway.id()

    _.merge {}, super,
      things: things
      exits: exits
