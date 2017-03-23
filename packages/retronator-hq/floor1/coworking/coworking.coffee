LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Coworking extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Coworking'
  @url: -> 'retronator/coworking'

  @version: -> '0.0.1'

  @fullName: -> "Coworking space"
  @shortName: -> "coworking"
  @description: ->
    "
      The passageway opens to a dimly-lit room with a cyberpunk hacker vibe to it.
      Tables shaped like tetrominos fill the space and hold workstations
      for the permanent residents of the coworking space.
    "
  
  @initialize()

  things: -> [
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.East}": HQ.Passage
    "#{Vocabulary.Keys.Directions.Down}": HQ.Basement
