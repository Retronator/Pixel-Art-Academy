LOI = LandsOfIllusions
Apartment = SanFrancisco.Apartment

Vocabulary = LOI.Parser.Vocabulary

class Apartment.Entrance extends LOI.Adventure.Location
  @id: -> 'SanFrancisco.Apartment.Entrance'
  @url: -> 'sf/apartment/entrance'
  @region: -> Apartment

  @version: -> '0.0.1'

  @fullName: -> "apartment building entrance"
  @shortName: -> "entrance"
  @description: ->
    "
      You are in your apartment building's entrance lobby.
      Your floor is just up the stairs, while the way out leads into San Francisco.
    "
  
  @initialize()

  constructor: ->
    super

  things: -> [
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.Out}": SanFrancisco.Soma.ChinaBasinPark
    "#{Vocabulary.Keys.Directions.Up}": Apartment.Hallway
