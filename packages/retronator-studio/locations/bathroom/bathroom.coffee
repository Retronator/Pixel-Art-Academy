LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action
Talking = LOI.Adventure.Ability.Talking

class HQ.Locations.Studio.Bathroom extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.Studio.Bathroom'
  @url: -> 'retronator/studio/bathroom'
  @scriptUrls: -> [
    'retronator_hq/hq.script'
  ]

  @version: -> '0.0.1'

  @fullName: -> "Studio bathroom"
  @shortName: -> "bathroom"
  @description: ->
    "
      You are in a compact bathroom with all the necessities: toilet, sink, shower and a couple of cabinets.
    "

  @initialize()

  constructor: ->
    super

  @state: ->
    things = {}

    exits = {}
    exits[Vocabulary.Keys.Directions.Out] = HQ.Locations.Studio.Hallway.id()
    exits[Vocabulary.Keys.Directions.West] = HQ.Locations.Studio.Hallway.id()

    _.merge {}, super,
      things: things
      exits: exits
