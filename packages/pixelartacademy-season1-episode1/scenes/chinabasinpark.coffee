LOI = LandsOfIllusions
PAA = PixelArtAcademy
E1 = PixelArtAcademy.Season1.Episode1
HQ = Retronator.HQ
SF = SanFrancisco

Vocabulary = LOI.Parser.Vocabulary

class E1.ChinaBasinPark extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.ChinaBasinPark'

  @location: -> SF.Soma.ChinaBasinPark

  @initialize()

  exits: ->
    "#{Vocabulary.Keys.Directions.In}": SF.Apartment.Entrance
    "#{Vocabulary.Keys.Directions.South}": SF.Apartment.Entrance
