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
    'retronator_hq/actors/elevatorbutton.script'
  ]

  @fullName: -> "Retronator Store"
  @shortName: -> "store"
  @description: ->
    "
      You enter a hall full of shelves that give you that warm, bookstore feeling. Ah, you feel at home already.
      To the north you see the checkout counter.
    "
  
  @initialize()

  constructor: ->
    super

    HQ.Locations.Elevator.setupElevatorExit
      location: @
      floor: 2

  initialState: ->
    things = {}
    things[HQ.Locations.Store.Shelf.PreOrders.id()] = displayOrder: 0
    things[HQ.Locations.Store.ShoppingCart.id()] = displayOrder: 1
    things[HQ.Actors.ElevatorButton.id()] = displayOrder: 2

    console.log "init store", things

    exits = {}
    exits[Vocabulary.Keys.Directions.North] = HQ.Locations.Store.Checkout.id()

    _.merge {}, super,
      things: things
      exits: exits

  onScriptsLoaded: ->
    # Elevator button
    HQ.Actors.ElevatorButton.setupButton
      location: @
      floor: 2
