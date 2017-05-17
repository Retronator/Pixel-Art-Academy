LOI = LandsOfIllusions
Soma = SanFrancisco.Soma

Vocabulary = LOI.Parser.Vocabulary

class Soma.Caltrain extends LOI.Adventure.Location
  @id: -> 'SanFrancisco.Soma.Caltrain'
  @url: -> 'sf/caltrain'
  @region: -> Soma

  @version: -> '0.0.1'

  @fullName: -> "Caltrain carriage"
  @shortName: -> "train"
  @description: ->
    "
      You are in a Caltrain carriage of a train running between San Francisco and San Jose.
    "
  
  @initialize()

  constructor: ->
    super

  things: -> [
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.Out}": Soma.FourthAndKing
    "#{Vocabulary.Keys.Directions.East}": Soma.FourthAndKing
