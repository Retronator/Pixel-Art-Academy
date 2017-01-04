LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Adventure.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action
Talking = LOI.Adventure.Ability.Talking

class HQ.Locations.Studio extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.Studio'
  @url: -> 'retronator/studio'
  @scriptUrls: -> [
    'retronator_hq/hq.script'
  ]

  @version: -> '0.0.1'

  @fullName: -> "Painting studio"
  @shortName: -> "studio"
  @description: ->
    "
      Fourth floor of the headquarters is a spacious apartment, clearly doubling as a painting studio.
      Easels are spread throughout the space together with a drafting table by the wall.
      To the west the room continues into a kitchen and a hall southwest.
    "
  
  @initialize()

  constructor: ->
    super

  @state: ->
    things = {}

    exits = {}
    exits[Vocabulary.Keys.Directions.Down] = HQ.Locations.Theater.id()
    exits[Vocabulary.Keys.Directions.South] = HQ.Locations.Theater.id()
    exits[Vocabulary.Keys.Directions.West] = HQ.Locations.Studio.Kitchen.id()
    exits[Vocabulary.Keys.Directions.Southwest] = HQ.Locations.Studio.Hallway.id()

    _.merge {}, super,
      things: things
      exits: exits
