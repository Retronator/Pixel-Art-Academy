LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class HQ.Residence extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Residence'
  @url: -> 'retronator/residence'
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
    exits[Vocabulary.Keys.Directions.Down] = HQ..Theater.id()
    exits[Vocabulary.Keys.Directions.South] = HQ..Theater.id()
    exits[Vocabulary.Keys.Directions.West] = HQ.Residence.Kitchen.id()
    exits[Vocabulary.Keys.Directions.Southwest] = HQ.Residence.Hallway.id()

    _.merge {}, super,
      things: things
      exits: exits
