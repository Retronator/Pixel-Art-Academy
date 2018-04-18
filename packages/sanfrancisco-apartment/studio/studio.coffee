LOI = LandsOfIllusions
Apartment = SanFrancisco.Apartment

Vocabulary = LOI.Parser.Vocabulary

class Apartment.Studio extends LOI.Adventure.Location
  @id: -> 'SanFrancisco.Apartment.Studio'
  @url: -> 'sf/apartment/studio'
  @region: -> Apartment

  @version: -> '0.0.1'

  @fullName: -> "studio apartment"
  @shortName: -> "studio"
  @description: ->
    "
      You are in _char's_ studio apartment in San Francisco. It's not much, and the rent is insanely high, but that's
      the price you pay to be in the tech capital of the world.
    "
  
  @initialize()

  constructor: ->
    super

  things: -> [
    @constructor.Computer
    @constructor.Bed
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.Out}": Apartment.Hallway
