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
    @colors new C1.Challenges.Drawing.Tutorial.Colors
    @helpers new C1.Challenges.Drawing.Tutorial.Helpers

  things: ->
    things = [
      @basics()
    ]

    basicsShortcuts = _.find @basics().assets(), (asset) -> asset instanceof C1.Challenges.Drawing.Tutorial.Basics.Shortcuts

    things.push @colors(), @helpers() if basicsShortcuts?.completed()

    things
