LOI = LandsOfIllusions
C3 = SanFrancisco.C3

Vocabulary = LOI.Parser.Vocabulary

class C3.Lobby extends LOI.Construct.Location
  @id: -> 'SanFrancisco.C3.Lobby'
  @url: -> 'c3/lobby'
  @region: -> SanFrancisco.Soma

  @version: -> '0.0.1'

  @fullName: -> "Character Construction Center lobby"
  @shortName: -> "lobby"
  @description: ->
    "
      The lobby of the Cyborg Construction Center, or C3 for short, is spacious and emits a high-tech vibe.
      Scientists in their white coats walk around with determination.
      Design Control with Manufacturing lies in the north.
      A hallway to the east can take you to Behavior and the Stasis Chamber.
    "

  @initialize()

  constructor: ->
    super

  destroy: ->
    super

  exits: ->
    "#{Vocabulary.Keys.Directions.West}": SanFrancisco.Soma.C3
    "#{Vocabulary.Keys.Directions.Out}": SanFrancisco.Soma.C3
    "#{Vocabulary.Keys.Directions.North}": C3.Design
    "#{Vocabulary.Keys.Directions.East}": C3.Hallway
