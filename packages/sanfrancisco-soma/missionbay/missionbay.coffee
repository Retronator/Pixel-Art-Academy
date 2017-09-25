LOI = LandsOfIllusions
Soma = SanFrancisco.Soma

Vocabulary = LOI.Parser.Vocabulary

class Soma.MissionBay extends LOI.Adventure.Location
  @id: -> 'SanFrancisco.Soma.MissionBay'
  @url: -> 'sf/mission-bay'
  @region: -> Soma

  @version: -> '0.0.1'

  @fullName: -> "San Francisco UCSF/Mission Bay Station"
  @shortName: -> "Mission Bay"
  @description: ->
    "
      You are at the UCSF/Mission Bay Muni station. University of California San Francisco Medical Center makes up
      most of the neighborhood, with Uber's fancy HQ and the Golden State Warriors' Chase Center highlighting the rest.
    "
  
  @initialize()

  constructor: ->
    super

  things: -> [
    Soma.Items.Muni
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.North}": Soma.MissionRock
    "#{Vocabulary.Keys.Directions.Southeast}": Soma.C3
