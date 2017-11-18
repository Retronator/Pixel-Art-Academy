LOI = LandsOfIllusions
Soma = SanFrancisco.Soma

Vocabulary = LOI.Parser.Vocabulary

class Soma.ChinaBasinPark extends LOI.Adventure.Location
  @id: -> 'SanFrancisco.Soma.ChinaBasinPark'
  @url: -> 'sf/china-basin-park'
  @region: -> Soma

  @version: -> '0.0.1'

  @fullName: -> "China Basin Park"
  @description: ->
    "
      You are in a lively park by Pier 48.
      If you look across the China Basin, you can see the AT&T park, and further in the distance the Bay Bridge.
      Behind you, a newly developed apartment building rises into the sky.
    "
  
  @initialize()

  constructor: ->
    super

  things: -> [
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.Southwest}": Soma.MissionRock
    "#{Vocabulary.Keys.Directions.Northwest}": Soma.SecondAndKing
