LOI = LandsOfIllusions
Soma = SanFrancisco.Soma

Vocabulary = LOI.Parser.Vocabulary

class Soma.Transbay extends LOI.Adventure.Location
  @id: -> 'SanFrancisco.Soma.Transbay'
  @url: -> 'sf/transbay-transit-center'
  @region: -> Soma

  @version: -> '0.0.1'

  @fullName: -> "San Francisco Transbay Transit Center"
  @shortName: -> "Transbay Center"
  @description: ->
    "
      You are in the newly-built Transbay Transit Center in San Francisco, the new hub in downtown.
      There are many ways out of here, but you're most interested in going southwest to Retronator HQ on 2nd Street.
    "
  
  @initialize()

  constructor: ->
    super

  things: -> [
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.Southwest}": Soma.SecondStreet
