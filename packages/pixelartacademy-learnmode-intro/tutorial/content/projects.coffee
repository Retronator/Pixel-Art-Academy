PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

PixelArtSoftware = PAA.Challenges.Drawing.PixelArtSoftware

class LM.Intro.Tutorial.Content.Projects extends LM.Content
  @id: -> 'LearnMode.Intro.Tutorial.Content.Projects'

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

  status: -> if PAA.PixelBoy.Apps.LearnMode.isAppUnlocked PAA.PixelBoy.Apps.Pico8.id() then LM.Content.Status.Unlocked else LM.Content.Status.Locked

  class @Snake extends LM.Content
    @id: -> 'LearnMode.Intro.Tutorial.Content.Projects.Snake'

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

        @progress = new LM.Content.Progress.ManualProgress
          content: @
          completed: =>
            return unless projectId = PAA.Pico8.Cartridges.Snake.Project.state 'activeProjectId'
            return unless project = PAA.Practice.Project.documents.findOne projectId

            return unless asset = _.find project.assets, (asset) => asset.id is @constructor.asset.id()
            return unless bitmap = LOI.Assets.Bitmap.documents.findOne asset.bitmapId

            # We know the player has changed the bitmap if the history position is not zero.
            return unless bitmap.historyPosition

            true

      status: -> LM.Content.Status.Unlocked

    class @Body extends @Sprite
      @id: -> 'LearnMode.Intro.Tutorial.Content.Projects.Snake.Body'

      @asset = PAA.Pico8.Cartridges.Snake.Body

      @initialize()

    class @Food extends @Sprite
      @id: -> 'LearnMode.Intro.Tutorial.Content.Projects.Snake.Food'

      @asset = PAA.Pico8.Cartridges.Snake.Food

      @initialize()
