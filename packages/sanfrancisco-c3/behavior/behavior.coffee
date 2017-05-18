LOI = LandsOfIllusions
C3 = SanFrancisco.C3

Vocabulary = LOI.Parser.Vocabulary

class C3.Behavior extends LOI.Construct.Location
  @id: -> 'SanFrancisco.C3.Behavior'
  @url: -> 'c3/behavior-setup'
  @region: -> C3

  @version: -> '0.0.1'

  @fullName: -> "Character Construction Center Behavior Setup"
  @shortName: -> "Behavior"
  @description: ->
    "
      Behavior Setup is an isolated room at the east end of the manufacturing hall.
      Machine noises are replaced with hushing of fans as supercomputers run machine learning algorithms and behavior
      simulations. Several workstations are lined up at the wall, each facing its own window that reveals a small test
      room behind it.
    "

  @initialize()

  constructor: ->
    super

  destroy: ->
    super

  exits: ->
    "#{Vocabulary.Keys.Directions.West}": C3.Design
    "#{Vocabulary.Keys.Directions.South}": C3.Hallway
    "#{Vocabulary.Keys.Directions.East}": C3.Stasis
