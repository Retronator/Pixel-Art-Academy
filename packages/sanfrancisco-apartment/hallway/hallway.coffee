LOI = LandsOfIllusions
Apartment = SanFrancisco.Apartment

Vocabulary = LOI.Parser.Vocabulary

class Apartment.Hallway extends LOI.Adventure.Location
  @id: -> 'SanFrancisco.Apartment.Hallway'
  @url: -> 'sf/apartment/hallway'
  @region: -> Apartment

  @version: -> '0.0.1'

  @fullName: -> "apartment building hallway"
  @shortName: -> "hallway"
  @description: ->
    "
      You are in the hallway in front of your apartment. You can go in or down the stairs to the lobby.
    "
  
  @initialize()

  constructor: ->
    super

  things: -> [
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.In}": Apartment.Studio
    "#{Vocabulary.Keys.Directions.Down}": Apartment.Entrance
