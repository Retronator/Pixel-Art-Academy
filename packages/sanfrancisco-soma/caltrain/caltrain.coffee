LOI = LandsOfIllusions
Soma = SanFrancisco.Soma

Vocabulary = LOI.Parser.Vocabulary

class Soma.Caltrain extends LOI.Adventure.Location
  @id: -> 'SanFrancisco.Soma.Caltrain'
  @url: -> 'sf/caltrain'
  @scriptUrls: -> [
  ]

  @version: -> '0.0.1'

  @fullName: -> "Caltrain carriage"
  @shortName: -> "Caltrain"
  @description: ->
    "
      You are in a carriage of a Caltrain running between San Francisco and San Jose.
    "
  
  @initialize()

  constructor: ->
    super

  things: -> [
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.Out}": Soma.FourthAndKing
