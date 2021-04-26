LOI = LandsOfIllusions
Soma = SanFrancisco.Soma

Vocabulary = LOI.Parser.Vocabulary

class Soma.MosconeCenter extends LOI.Adventure.Location
  @id: -> 'SanFrancisco.Soma.MosconeCenter'
  @url: -> 'sf/moscone-center'
  @region: -> Soma

  @version: -> '0.0.1'

  @fullName: -> "Moscone Center"
  @shortName: -> "Moscone"
  @description: ->
    "
      You are on the corner of 4th and Howard in the SOMA district of San Francisco. 
      The three halls of Moscone convention center envelop the intersection.
      Game developers are rushing from hall to hall — GDC is in town!
    "
  
  @initialize()

  constructor: ->
    super arguments...

  things: -> [
    Soma.Actors.James
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.Southeast}": Soma.FourthAndKing
    "#{Vocabulary.Keys.Directions.Northeast}": Soma.SecondStreet
    "#{Vocabulary.Keys.Directions.Down}": Soma.MosconeStation
    "#{Vocabulary.Keys.Directions.Southwest}": Soma.MosconeStation
