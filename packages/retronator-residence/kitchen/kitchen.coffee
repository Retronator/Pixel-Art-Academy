LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Residence.Kitchen extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Residence.Kitchen'
  @url: -> 'retronator/residence/kitchen'
  @scriptUrls: -> [
    'retronator_hq/hq.script'
  ]

  @version: -> '0.0.1'

  @fullName: -> "Studio kitchen"
  @shortName: -> "kitchen"
  @description: ->
    "
      The northwest corner of the studio is home to a small kitchen with an island and a dining table for 6 people.
      A small hallway to the south connects with the closed rooms of the apartment.
    "
  
  @initialize()

  constructor: ->
    super

  @state: ->
    things = {}

    exits = {}
    exits[Vocabulary.Keys.Directions.East] = HQ.Residence.id()
    exits[Vocabulary.Keys.Directions.South] = HQ.Residence.Hallway.id()

    _.merge {}, super,
      things: things
      exits: exits
