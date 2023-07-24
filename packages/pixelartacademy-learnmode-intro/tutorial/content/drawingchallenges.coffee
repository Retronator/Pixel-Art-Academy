PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

PixelArtSoftware = PAA.Challenges.Drawing.PixelArtSoftware

class LM.Intro.Tutorial.Content.DrawingChallenges extends LM.Content
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.DrawingChallenges'

  @displayName: -> "Drawing challenges"

  @unlockInstructions: -> "Complete the Pixel art tools: basics tutorial to unlock drawing challenges."

  @contents: -> [
    @CopyReference
  ]

  @initialize()

  constructor: ->
    super arguments...

    @progress = new LM.Content.Progress.ContentProgress
      content: @
      weight: 0.1
      totalUnits: "artworks"
      totalRecursive: true

  status: -> if PAA.Tutorials.Drawing.PixelArtTools.Basics.completed() then LM.Content.Status.Unlocked else LM.Content.Status.Locked

  class @CopyReference extends LM.Content
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.DrawingChallenges.CopyReference'

    @displayName: -> "Copy a reference"

    @contents: -> [
      @SmallMonochrome
      @SmallColored
      @BigMonochrome
      @BigColored
    ]

    @initialize()

    constructor: ->
      super arguments...

      @progress = new LM.Content.Progress.ManualProgress
        content: @
        units: "sprites"

        completed: => PixelArtSoftware.completed()

        unitsCount: =>
          _.values(PixelArtSoftware.copyReferenceClasses).length

        completedUnitsCount: =>
          assets = PixelArtSoftware.state('assets') or []
          _.filter(assets, (asset) => asset.completed).length

        requiredUnitsCount: => 1

    status: -> LM.Content.Status.Unlocked

    class @SpritesGroup extends LM.Content
      @prefixFilter = null # Override with the class name prefix that defines this group.

      constructor: ->
        super arguments...

        @progress = new LM.Content.Progress.ManualProgress
          content: @
          units: "sprites"

          completed: => @progress.completedUnitsCount() >= 1

          unitsCount: =>
            (id for id of PixelArtSoftware.copyReferenceClasses when @_assetBelongsToGroup id).length

          completedUnitsCount: =>
            assets = PixelArtSoftware.state('assets') or []
            _.filter(assets, (asset) => @_assetBelongsToGroup(asset.id) and asset.completed).length

          requiredUnitsCount: => 1

      _assetBelongsToGroup: (assetId) -> _.last(assetId.split '.').substring(0, 2) is @constructor.prefixFilter

    class @SmallMonochrome extends @SpritesGroup
      @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.DrawingChallenges.CopyReference.SmallMonochrome'

      @displayName: -> "Small monochrome sprites"

      @initialize()

      @prefixFilter = 'MS'

      status: -> LM.Content.Status.Unlocked

    class @SmallColored extends @SpritesGroup
      @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.DrawingChallenges.CopyReference.SmallColored'

      @displayName: -> "Small colored sprites"

      @unlockInstructions: -> "Complete the Colors tutorial to unlock colored sprites."

      @initialize()

      @prefixFilter = 'CS'

      status: -> if PAA.Tutorials.Drawing.PixelArtTools.Colors.completed() then LM.Content.Status.Unlocked else LM.Content.Status.Locked

    class @BigMonochrome extends @SpritesGroup
      @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.DrawingChallenges.CopyReference.BigMonochrome'

      @displayName: -> "Big monochrome sprites"

      @unlockInstructions: -> "Complete the Helpers tutorial to unlock big sprites."

      @initialize()

      @prefixFilter = 'MB'

      status: -> if PAA.Tutorials.Drawing.PixelArtTools.Helpers.completed() then LM.Content.Status.Unlocked else LM.Content.Status.Locked

    class @BigColored extends @SpritesGroup
      @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Content.DrawingChallenges.CopyReference.BigColored'

      @displayName: -> "Big colored sprites"

      @unlockInstructions: -> "Complete the Colors and Helpers tutorials to unlock big colored sprites."

      @initialize()

      @prefixFilter = 'CB'

      status: -> if PAA.Tutorials.Drawing.PixelArtTools.Colors.completed() and PAA.Tutorials.Drawing.PixelArtTools.Helpers.completed() then LM.Content.Status.Unlocked else LM.Content.Status.Locked
