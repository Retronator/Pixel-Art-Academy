LOI = LandsOfIllusions
C3 = SanFrancisco.C3

Vocabulary = LOI.Parser.Vocabulary

class C3.Stasis extends LOI.Adventure.Location
  @id: -> 'SanFrancisco.C3.Stasis'
  @url: -> 'c3/stasis'
  @region: -> C3

  @version: -> '0.0.1'

  @fullName: -> "Character Construction Center Stasis Chamber"
  @shortName: -> "Stasis"
  @description: ->
    "
      The Stasis Chamber holds a line of glass vats that stretch from floor to ceiling.
      Cybernetic bodies are suspended in them, the density of the liquid balanced exactly to have them floating without weight.
    "

  @initialize()

  constructor: ->
    super

  destroy: ->
    super

  exits: ->
    "#{Vocabulary.Keys.Directions.West}": C3.Behavior
    "#{Vocabulary.Keys.Directions.Southwest}": C3.Hallway
