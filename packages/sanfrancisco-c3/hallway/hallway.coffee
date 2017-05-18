LOI = LandsOfIllusions
C3 = SanFrancisco.C3

Vocabulary = LOI.Parser.Vocabulary

class C3.Hallway extends LOI.Construct.Location
  @id: -> 'SanFrancisco.C3.Hallway'
  @url: -> 'c3/hallway'
  @region: -> SanFrancisco.Soma

  @version: -> '0.0.1'

  @fullName: -> "Character Construction Center hallway"
  @shortName: -> "hallway"
  @description: ->
    "
      You enter an unassuming hallway that runs east-west along the length of the building, allowing you to reach
      Behavior Setup in the north and the Stasis Chamber further northeast.
    "

  @initialize()

  constructor: ->
    super

  destroy: ->
    super

  exits: ->
    "#{Vocabulary.Keys.Directions.North}": Soma.Behavior
    "#{Vocabulary.Keys.Directions.Northeast}": Soma.Stasis
    "#{Vocabulary.Keys.Directions.West}": Soma.Lobby
