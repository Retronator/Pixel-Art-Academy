LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1

Vocabulary = LOI.Parser.Vocabulary

class C1.DrawingTutorial extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.DrawingTutorial'

  @location: -> PAA.Practice.Challenges.Drawing

  @initialize()

  constructor: ->
    super

    @drawingTutorial = new C1.Challenges.Drawing.Tutorial

  things: -> [
    @drawingTutorial
  ]

  ready: ->
    @drawingTutorial.ready()
