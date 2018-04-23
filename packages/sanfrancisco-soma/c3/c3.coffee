LOI = LandsOfIllusions
Soma = SanFrancisco.Soma

Vocabulary = LOI.Parser.Vocabulary

class Soma.C3 extends LOI.Adventure.Location
  @id: -> 'SanFrancisco.Soma.C3'
  @url: -> 'sf/c3'
  @region: -> Soma

  @version: -> '0.0.1'

  @fullName: -> "Cyborg Construction Center entrance"
  @shortName: -> "C3 entrance"
  @description: ->
    "
      You are in front of a building with big glass sliding doors to the east. The title Cyborg Construction Center is
      printed across them. A little above, C3 is written in a way that resembles brain hemispheres.
    "
  
  @initialize()

  constructor: ->
    super

  things: -> [
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.Northwest}": Soma.MissionBay
