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

    @essentialTools = new ReactiveField null
    @colorTools = new ReactiveField null
    @helpers = new ReactiveField null

    @essentialTools new C1.Challenges.Drawing.Tutorial.EssentialTools
    @colorTools new C1.Challenges.Drawing.Tutorial.ColorTools
    @helpers new C1.Challenges.Drawing.Tutorial.Helpers

  things: ->
    things = [
      @essentialTools()
    ]

    pencil = _.find @essentialTools().assets(), (asset) -> asset instanceof C1.Challenges.Drawing.Tutorial.EssentialTools.Pencil

    things.push @colorTools(), @helpers() if pencil?.completed()

    things
