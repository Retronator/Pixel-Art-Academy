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

    @unlockInstructions: -> "Score some points in the Snake game on PICO-8 to unlock the Snake project."

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

    class @Body extends LM.Content.AssetContent
      @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.Projects.Snake.Body'

      @assetClass = PAA.Pico8.Cartridges.Snake.Body

      @initialize()

      status: -> LM.Content.Status.Unlocked

    class @Food extends LM.Content.AssetContent
      @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.Projects.Snake.Food'

      @assetClass = PAA.Pico8.Cartridges.Snake.Food

      @initialize()
  
      status: -> LM.Content.Status.Unlocked
