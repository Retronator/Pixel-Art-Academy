LOI = LandsOfIllusions
Soma = SanFrancisco.Soma

Vocabulary = LOI.Parser.Vocabulary

class Soma.MissionRock extends LOI.Adventure.Location
  @id: -> 'SanFrancisco.Soma.MissionRock'
  @url: -> 'sf/mission-rock'
  @region: -> Soma

  @version: -> '0.0.1'

  @fullName: -> "San Francisco Mission Rock"
  @shortName: -> "Mission Rock"
  @description: ->
    "
      Mission Rock bayfront is undergoing big redevelopment with new residential apartments rising up into the sky. 
      You can hardly believe this used to be a parking lot just a few years ago.
    "
  
  @initialize()

  constructor: ->
    super arguments...

  things: -> [
    Soma.Items.Muni
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.Northwest}": Soma.FourthAndKing
    "#{Vocabulary.Keys.Directions.South}": Soma.MissionBay
    "#{Vocabulary.Keys.Directions.Northeast}": Soma.ChinaBasinPark
