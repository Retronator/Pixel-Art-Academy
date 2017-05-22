LOI = LandsOfIllusions
Soma = SanFrancisco.Soma

Vocabulary = LOI.Parser.Vocabulary

class Soma.MosconeStation extends LOI.Adventure.Location
  @id: -> 'SanFrancisco.Soma.MosconeStation'
  @url: -> 'sf/moscone-station'
  @region: -> Soma

  @version: -> '0.0.1'

  @fullName: -> "Yerba Buena/Moscone Station"
  @shortName: -> "station"
  @description: ->
    "
      You are at the Yerba Buena/Moscone Station of the new Muni central subway.
      The T line train can take you south towards Mission Bay.
    "
  
  @initialize()

  constructor: ->
    super

  things: -> [
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.Up}": Soma.MosconeCenter
    "#{Vocabulary.Keys.Directions.Northeast}": Soma.MosconeCenter
