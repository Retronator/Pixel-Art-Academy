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
      You are at 4th and King Street Muni station.
      There is not much to do in this part of the city, but paths lead to downtown and and Mission Bay.
    "
  
  @initialize()

  constructor: ->
    super arguments...

  things: -> [
    Soma.Items.Muni
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.Northwest}": Soma.MosconeCenter
    "#{Vocabulary.Keys.Directions.Northeast}": Soma.SecondAndKing
    "#{Vocabulary.Keys.Directions.Southeast}": Soma.MissionRock
