LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Adventure.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action
Talking = LOI.Adventure.Ability.Talking

class HQ.Locations.Store extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.Store'
  @url: -> 'retronator/store'
  @scriptUrls: -> [
    'retronator_hq/hq.script'
  ]

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

  @initialState: ->
    things = {}
    things[HQ.Locations.Store.Shelf.PreOrders.id()] = displayOrder: 0

    exits = {}
    exits[Vocabulary.Keys.Directions.West] = HQ.Locations.Checkout.id()
    exits[Vocabulary.Keys.Directions.Northwest] = HQ.Locations.Chillout.id()
    exits[Vocabulary.Keys.Directions.Up] = HQ.Locations.Chillout.id()

    _.merge {}, super,
      things: things
      exits: exits
