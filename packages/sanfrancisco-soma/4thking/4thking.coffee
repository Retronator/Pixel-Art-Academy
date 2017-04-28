LOI = LandsOfIllusions
Soma = SanFrancisco.Soma

Vocabulary = LOI.Parser.Vocabulary

class Soma.FourthAndKing extends LOI.Adventure.Location
  @id: -> 'SanFrancisco.Soma.FourthAndKing'
  @url: -> 'sf/4th-and-king'
  @region: -> Soma

  @version: -> '0.0.1'

  @fullName: -> "San Francisco 4th and King Street Caltrain station"
  @shortName: -> "4th and King"
  @description: ->
    "
      You are at the San Francisco 4th and King Street Caltrain station.
      There is not much to do in this part of the city. Downtown skyscrapers seem more enticing
      and can be reached by traveling northwest on 4th street.
    "
  
  @initialize()

  constructor: ->
    super

  things: -> [
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.In}": Soma.Caltrain
    "#{Vocabulary.Keys.Directions.Northwest}": Soma.MosconeCenter
