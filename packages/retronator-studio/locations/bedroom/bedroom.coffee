LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action
Talking = LOI.Adventure.Ability.Talking

class HQ.Locations.Studio.Bedroom extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.Studio.Bedroom'
  @url: -> 'retronator/studio/bedroom'
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
    exits[Vocabulary.Keys.Directions.North] = HQ.Locations.Studio.Hallway.id()
    exits[Vocabulary.Keys.Directions.Out] = HQ.Locations.Studio.Hallway.id()

    _.merge {}, super,
      things: things
      exits: exits
