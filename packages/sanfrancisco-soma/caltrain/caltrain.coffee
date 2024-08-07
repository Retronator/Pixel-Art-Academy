LOI = LandsOfIllusions
Soma = SanFrancisco.Soma

Vocabulary = LOI.Parser.Vocabulary

class Soma.Caltrain extends LOI.Adventure.Location
  @id: -> 'SanFrancisco.Soma.Caltrain'
  @url: -> 'sf/caltrain'
  @region: -> Soma

  @version: -> '0.0.1'

  @fullName: -> "Caltrain carriage"
  @shortName: -> "caltrain"
  @description: ->
    "
      You are in a Caltrain carriage of a train running between San Francisco and San Jose.
    "
  
  @initialize()

  constructor: ->
    super arguments...

  things: -> [
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.Out}": Soma.Transbay
    "#{Vocabulary.Keys.Directions.North}": Soma.Transbay
