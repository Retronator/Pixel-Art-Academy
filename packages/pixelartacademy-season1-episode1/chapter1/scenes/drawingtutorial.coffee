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

    @basics = new ReactiveField null
    @colors = new ReactiveField null
    @helpers = new ReactiveField null

    @basics new C1.Challenges.Drawing.Tutorial.Basics

  things: ->
    things = [
      @basics()
    ]

    if @basics().isAssetCompleted C1.Challenges.Drawing.Tutorial.Basics.Shortcuts
      unless colors = @colors()
        colors = new C1.Challenges.Drawing.Tutorial.Colors
        @colors colors

      unless helpers = @helpers()
        helpers = new C1.Challenges.Drawing.Tutorial.Helpers
        @helpers helpers

      things.push colors, helpers

    things
