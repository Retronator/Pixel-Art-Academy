LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class HQ.LandsOfIllusions extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.LandsOfIllusions'
  @url: -> 'retronator/landsofillusions'

  @version: -> '0.0.1'

  @fullName: -> "Lands of Illusions VR center"
  @shortName: -> "Lands of Illusions"
  @description: ->
    "
      The hallway of the VR center leads from the reception deck towards a number of adjacent immersion rooms.
      There is an open door to one on the north side.
    "

  @initialize()

  constructor: ->
    super

  things: -> []

  exits: ->
    "#{Vocabulary.Keys.Directions.West}": HQ.Basement
    "#{Vocabulary.Keys.Directions.North}": HQ.LandsOfIllusions.Room
    "#{Vocabulary.Keys.Directions.In}": HQ.LandsOfIllusions.Room
