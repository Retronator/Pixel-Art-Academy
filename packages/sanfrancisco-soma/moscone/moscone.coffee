LOI = LandsOfIllusions
Soma = SanFrancisco.Soma

Vocabulary = LOI.Parser.Vocabulary

class Soma.MosconeCenter extends LOI.Adventure.Location
  @id: -> 'SanFrancisco.Soma.MosconeCenter'
  @url: -> 'sf/moscone-center'
  @scriptUrls: -> [
  ]

  @version: -> '0.0.1'

  @fullName: -> "Moscone Center"
  @shortName: -> "Moscone"
  @description: ->
    "
      You are on the corner of 4th and Howard in the SOMA district of San Francisco. 
      The three halls of Moscone convention center envelop the intersection.
      Game developers are rushing from hall to hall — GDC is in town!
      Howard street can take you northeast to 2nd street.
    "
  
  @initialize()

  constructor: ->
    super

  things: -> [
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.Southeast}": Soma.FourthAndKing
    "#{Vocabulary.Keys.Directions.Northeast}": Soma.SecondStreet
