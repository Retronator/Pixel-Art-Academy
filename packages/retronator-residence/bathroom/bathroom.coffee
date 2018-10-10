LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Residence.Bathroom extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Residence.Bathroom'
  @url: -> 'retronator/residence/bathroom'
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
    exits[Vocabulary.Keys.Directions.Out] = HQ.Residence.Hallway.id()
    exits[Vocabulary.Keys.Directions.West] = HQ.Residence.Hallway.id()

    _.merge {}, super,
      things: things
      exits: exits
