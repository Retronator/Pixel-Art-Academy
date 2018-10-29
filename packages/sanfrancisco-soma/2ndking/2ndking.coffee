LOI = LandsOfIllusions
Soma = SanFrancisco.Soma

Vocabulary = LOI.Parser.Vocabulary

class Soma.SecondAndKing extends LOI.Adventure.Location
  @id: -> 'SanFrancisco.Soma.SecondAndKing'
  @url: -> 'sf/2nd-and-king'
  @region: -> Soma

  @version: -> '0.0.1'

  @fullName: -> "San Francisco 2nd and King Station"
  @shortName: -> "2nd and King"
  @description: ->
    "
      You are in front of the famous AT&T Park baseball stadium, the home of the San Francisco Giants.
      2nd street goes northwest and King street southwest.
    "
  
  @initialize()

  constructor: ->
    super arguments...

  things: -> [
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.Northwest}": Soma.SecondStreet
    "#{Vocabulary.Keys.Directions.Southwest}": Soma.FourthAndKing
    "#{Vocabulary.Keys.Directions.Southeast}": Soma.ChinaBasinPark
