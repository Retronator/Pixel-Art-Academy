LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Passage extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Passage'
  @url: -> 'retronator/passage'

  @version: -> '0.0.1'

  @fullName: -> "1st floor passage"
  @shortName: -> "passage"
  @description: ->
    "
      You are in a comfortable tunnel like passage that connects the café and coworking space east–west.
      The building's elevator can be called with the button by the south doors and there's also a restroom on the
      north side.
    "
  
  @initialize()

  things: -> [
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.East}": HQ.Cafe
    "#{Vocabulary.Keys.Directions.West}": HQ.Coworking
    "#{Vocabulary.Keys.Directions.North}": HQ.Restroom
    "#{Vocabulary.Keys.Directions.South}": HQ.Cafe
