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
      You are in the entrance lobby of _char's_ apartment building.
      _Their_ floor is just up the stairs, while the way out leads into San Francisco.
    "
  
  @initialize()

  constructor: ->
    super

  things: -> [
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.Out}": SanFrancisco.Soma.ChinaBasinPark
    "#{Vocabulary.Keys.Directions.North}": SanFrancisco.Soma.ChinaBasinPark
    "#{Vocabulary.Keys.Directions.Up}": Apartment.Hallway
    "#{Vocabulary.Keys.Directions.Northeast}": Apartment.Hallway
