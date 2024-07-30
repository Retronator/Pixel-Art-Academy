PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

PixelArtSoftware = PAA.Challenges.Drawing.PixelArtSoftware

class LM.Intro.Tutorial.Content.Projects extends LM.Content
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.Projects'

  @displayName: -> "Projects"

  @unlockInstructions: -> "Unlock the PICO-8 app to get access to projects."

  @contents: -> [
    @Snake
  ]

  @initialize()

  constructor: ->
    super arguments...

    @progress = new LM.Content.Progress.ContentProgress
      content: @
      weight: 2
      totalUnits: "artworks"
      totalRecursive: true

  status: ->
    pixelArtSoftwareGoal = PAA.Learning.Goal.getAdventureInstanceForId LM.Intro.Tutorial.Goals.PixelArtSoftware.id()
    if pixelArtSoftwareGoal.completed() then @constructor.Status.Unlocked else @constructor.Status.Locked

  class @Snake extends LM.Content
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.Projects.Snake'

    @displayName: -> "Snake"

    @unlockInstructions: -> "Score at least 5 points in the Snake game on PICO-8 to unlock the Snake project."

    @contents: -> [
      @Body
      @Food
    ]

    @initialize()

    constructor: ->
      super arguments...

      @progress = new LM.Content.Progress.ContentProgress
        content: @
        units: "sprites"

    status: -> if LM.Intro.Tutorial.Goals.Snake.Play.completedConditions() then LM.Content.Status.Unlocked else LM.Content.Status.Locked

    class @Sprite extends LM.Content
      @asset = null # Override which project asset this sprite is.

      @displayName: -> @asset.displayName()

      constructor: ->
        super arguments...

        @progress = new LM.Content.Progress.ProjectAssetProgress
          content: @
          project: PAA.Pico8.Cartridges.Snake.Project
          asset: @constructor.asset

      status: -> LM.Content.Status.Unlocked

    class @Body extends @Sprite
      @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.Projects.Snake.Body'

      @asset = PAA.Pico8.Cartridges.Snake.Body

      @initialize()

    class @Food extends @Sprite
      @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.Projects.Snake.Food'

      @asset = PAA.Pico8.Cartridges.Snake.Food

      @initialize()
