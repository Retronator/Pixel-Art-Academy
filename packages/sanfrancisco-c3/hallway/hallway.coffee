LOI = LandsOfIllusions
C3 = SanFrancisco.C3

Vocabulary = LOI.Parser.Vocabulary

class C3.Hallway extends LOI.Adventure.Location
  @id: -> 'SanFrancisco.C3.Hallway'
  @url: -> 'c3/hallway'
  @region: -> C3

  @version: -> '0.0.1'

  @fullName: -> "Cyborg Construction Center hallway"
  @shortName: -> "hallway"
  @description: ->
    "
      You enter an unassuming hallway that runs along the length of the building, allowing you to reach
      Behavior Setup in the north and the Stasis Chamber further northeast.
    "

  @initialize()

  constructor: ->
    super arguments...

  destroy: ->
    super arguments...

  exits: ->
    "#{Vocabulary.Keys.Directions.North}": C3.Behavior
    "#{Vocabulary.Keys.Directions.Northeast}": C3.Stasis
    "#{Vocabulary.Keys.Directions.Southwest}": C3.Lobby
