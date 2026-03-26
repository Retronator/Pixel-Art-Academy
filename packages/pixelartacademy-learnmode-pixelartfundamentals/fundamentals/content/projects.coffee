PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

PixelArtSoftware = PAA.Challenges.Drawing.PixelArtSoftware

class LM.PixelArtFundamentals.Fundamentals.Content.Projects extends LM.Content
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects'
  @displayName: -> "Projects"
  @tags: -> [LM.Content.Tags.WIP]
  @contents: -> [
    @Pinball
    @Chess
    @PixelPaint
    @CityBuilder
    @BlockBreaker
  ]
  @initialize()

  constructor: ->
    super arguments...
    
    @progress = new LM.Content.Progress.ContentProgress
      content: @
      weight: 2
      totalUnits: "artworks"
      totalRecursive: true
      
  status: -> LM.Content.Status.Unlocked

  class @Pinball extends LM.Content
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Pinball'
    @displayName: -> "Pinball"
    @tags: -> [LM.Content.Tags.WIP]
    
    @unlockInstructions: -> "Complete the Smooth curves challenge to start the Pinball project."
    
    @contents: -> [
      @Ball
      @Playfield
      @GobbleHole
      @BallTrough
      @Bumper
      @Gate
      @Flipper
      @SpinningTarget
    ]
    
    @initialize()
    
    constructor: ->
      super arguments...
      
      @progress = new LM.Content.Progress.ContentProgress
        content: @
        units: "pinball parts"
    
    status: -> if LM.PixelArtFundamentals.pinballEnabled() then LM.Content.Status.Unlocked else LM.Content.Status.Locked
    
    class @Part extends LM.Content
      @asset = null # Override which project asset this sprite is.
      
      @displayName: -> @asset.displayName()
      
      constructor: ->
        super arguments...
        
        @progress = new LM.Content.Progress.ProjectAssetProgress
          content: @
          project: PAA.Pixeltosh.Programs.Pinball.Project
          asset: @constructor.asset
      
      status: -> LM.Content.Status.Unlocked
    
    class @Ball extends @Part
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Pinball.Ball'
      
      @asset = PAA.Pixeltosh.Programs.Pinball.Assets.Ball
      
      @initialize()
    
    class @Playfield extends @Part
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Pinball.Playfield'
      
      @asset = PAA.Pixeltosh.Programs.Pinball.Assets.Playfield
      
      @initialize()

    class @GobbleHole extends @Part
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Pinball.GobbleHole'

      @asset = PAA.Pixeltosh.Programs.Pinball.Assets.GobbleHole

      @initialize()

    class @BallTrough extends @Part
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Pinball.BallTrough'

      @asset = PAA.Pixeltosh.Programs.Pinball.Assets.BallTrough

      @initialize()

    class @Bumper extends @Part
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Pinball.Bumper'

      @asset = PAA.Pixeltosh.Programs.Pinball.Assets.Bumper

      @initialize()

    class @Gate extends @Part
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Pinball.Gate'

      @asset = PAA.Pixeltosh.Programs.Pinball.Assets.Gate

      @initialize()

    class @Flipper extends @Part
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Pinball.Flipper'

      @asset = PAA.Pixeltosh.Programs.Pinball.Assets.Flipper

      @initialize()

    class @SpinningTarget extends @Part
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Pinball.SpinningTarget'

      @asset = PAA.Pixeltosh.Programs.Pinball.Assets.SpinningTarget

      @initialize()
      
  class @BlockBreaker extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.BlockBreaker'
    @displayName: -> "Block breaker"
    @initialize()
  
  class @Chess extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Chess'
    @displayName: -> "Chess"
    @initialize()
  
  class @PixelPaint extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.PixelPaint'
    @displayName: -> "PixelPaint"
    @initialize()
  
  class @CityBuilder extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.CityBuilder'
    @displayName: -> "City builder"
    @initialize()
