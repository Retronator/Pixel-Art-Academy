LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Adventure.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action
Talking = LOI.Adventure.Ability.Talking

class HQ.Locations.Store.Checkout extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.Store.Checkout'
  @url: -> 'retronator/store/checkout'
  @scriptUrls: -> [
  ]

  @fullName: -> "Retronator Store checkout counter"
  @shortName: -> "checkout"
  @description: ->
    "
      You come to the counter and the cashier gives you a warm smile. On the wall there is a display similar
      to the one in the lobby. 
    "

  @initialize()

  constructor: ->
    super

  initialState: ->
    things = {}

    exits = {}
    exits[Vocabulary.Keys.Directions.South] = HQ.Locations.Store.id()

    _.merge {}, super,
      things: things
      exits: exits

  onScriptsLoaded: ->
