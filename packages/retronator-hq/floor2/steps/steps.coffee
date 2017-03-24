LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class HQ.Steps extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Steps'
  @url: -> 'retronator/steps'
  @scriptUrls: -> [
    'retronator-hq/hq.script'
  ]

  @version: -> '0.0.1'

  @fullName: -> "Retronator HQ lounge steps"
  @shortName: -> "steps"
  @description: ->
    "
      The stairs that lead to the second floor are accompanied by bigger steps, where a few hipster kids lounge glued
      to their laptops. You can continue up or down.
    "
  
  @initialize()

  constructor: ->
    super

  exits: ->
    "#{Vocabulary.Keys.Directions.Down}": HQ.Cafe
    "#{Vocabulary.Keys.Directions.Up}": HQ.Store
