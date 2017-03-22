LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class HQ.Store extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Store'
  @url: -> 'retronator/store'
  @scriptUrls: -> [
    'retronator-hq/hq.script'
  ]

  @version: -> '0.0.1'

  @fullName: -> "Retronator Store"
  @shortName: -> "store"
  @description: ->
    "
      The store opens towards the building's glass front facade. Tall shelves line the walls, divided into sections.
      Stairs curve northwest to the third floor.
    "
  
  @initialize()

  constructor: ->
    super

  @state: ->
    things = {}
    things[HQ.Store.Shelf.Game.id()] = displayOrder: 0
    things[HQ.Store.Shelf.Upgrades.id()] = displayOrder: 1

    exits = {}
    exits[Vocabulary.Keys.Directions.West] = HQ.Checkout.id()
    exits[Vocabulary.Keys.Directions.Northwest] = HQ.Chillout.id()
    exits[Vocabulary.Keys.Directions.Up] = HQ.Chillout.id()

    _.merge {}, super,
      things: things
      exits: exits
