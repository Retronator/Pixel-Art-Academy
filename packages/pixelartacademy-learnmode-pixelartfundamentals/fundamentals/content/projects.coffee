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
  
  class @Chess extends LM.Content
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Chess'
    @displayName: -> "Chess"
    @tags: -> [LM.Content.Tags.WIP]
    @contents: -> [
      @TwoDimensional
      @ThreeDimensional
    ]
    
    @initialize()
    
    status: -> LM.Content.Status.Unlocked
    
    constructor: ->
      super arguments...
      
      @progress = new LM.Content.Progress.ContentProgress
        content: @
        units: 'chess sets'
        
    class @PieceType extends LM.Content
      constructor: ->
        super arguments...
        
        pieceTypeClass = @constructor
        
        @progress = new LM.Content.Progress.ManualProgress
          content: @
          completed: -> @completedUnitsCount() is 2
          completedUnitsCount: ->
            return unless projectId = pieceTypeClass.project.state 'activeProjectId'
            return unless project = PAA.Practice.Project.documents.findOne projectId
            
            count = 0
            
            if whiteAsset = _.find project.assets, (asset) => asset.id is pieceTypeClass.whiteAsset.id()
              if whiteBitmap = LOI.Assets.Bitmap.documents.findOne whiteAsset.bitmapId
                count++ if whiteBitmap.historyPosition
            
            if blackAsset = _.find project.assets, (asset) => asset.id is pieceTypeClass.blackAsset.id()
              if blackBitmap = LOI.Assets.Bitmap.documents.findOne blackAsset.bitmapId
                count++ if blackBitmap.historyPosition

            count

          requiredUnitsCount: -> 2
          units: 'colors'
      
      status: -> LM.Content.Status.Unlocked
    
    class @TwoDimensional extends LM.Content
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Chess.TwoDimensional'
      @displayName: -> "2D"
      
      @unlockInstructions: -> "Complete the Pixel art fundamentals: size goal to start the 2D chess project."
      
      @contents: -> [
        @Pawn
        @Knight
        @Bishop
        @Rook
        @Queen
        @King
      ]
      
      @initialize()
      
      constructor: ->
        super arguments...
        
        @progress = new LM.Content.Progress.ContentProgress
          content: @
          units: "chess pieces"
      
      status: -> if LM.PixelArtFundamentals.Fundamentals.Goals.Size.completed() then LM.Content.Status.Unlocked else LM.Content.Status.Locked

      class @PieceType extends Chess.PieceType
        @project = PAA.Pixeltosh.Programs.Chess.Project.TwoDimensional

      class @Pawn extends TwoDimensional.PieceType
        @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Chess.TwoDimensional.Pawn'
        
        @displayName: -> "Pawn"
        
        @whiteAsset = PAA.Pixeltosh.Programs.Chess.Assets.TwoDimensional.Pawn.White
        @blackAsset = PAA.Pixeltosh.Programs.Chess.Assets.TwoDimensional.Pawn.Black
        
        @initialize()
      
      class @Knight extends TwoDimensional.PieceType
        @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Chess.TwoDimensional.Knight'
        
        @displayName: -> "Knight"
        
        @whiteAsset = PAA.Pixeltosh.Programs.Chess.Assets.TwoDimensional.Knight.White
        @blackAsset = PAA.Pixeltosh.Programs.Chess.Assets.TwoDimensional.Knight.Black

        @initialize()
      
      class @Bishop extends TwoDimensional.PieceType
        @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Chess.TwoDimensional.Bishop'
        
        @displayName: -> "Bishop"
        
        @whiteAsset = PAA.Pixeltosh.Programs.Chess.Assets.TwoDimensional.Bishop.White
        @blackAsset = PAA.Pixeltosh.Programs.Chess.Assets.TwoDimensional.Bishop.Black

        @initialize()
      
      class @Rook extends TwoDimensional.PieceType
        @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Chess.TwoDimensional.Rook'
        
        @displayName: -> "Rook"
        
        @whiteAsset = PAA.Pixeltosh.Programs.Chess.Assets.TwoDimensional.Rook.White
        @blackAsset = PAA.Pixeltosh.Programs.Chess.Assets.TwoDimensional.Rook.Black

        @initialize()
      
      class @Queen extends TwoDimensional.PieceType
        @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Chess.TwoDimensional.Queen'
        
        @displayName: -> "Queen"
        
        @whiteAsset = PAA.Pixeltosh.Programs.Chess.Assets.TwoDimensional.Queen.White
        @blackAsset = PAA.Pixeltosh.Programs.Chess.Assets.TwoDimensional.Queen.Black

        @initialize()
      
      class @King extends TwoDimensional.PieceType
        @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Chess.TwoDimensional.King'
        
        @displayName: -> "King"
        
        @whiteAsset = PAA.Pixeltosh.Programs.Chess.Assets.TwoDimensional.King.White
        @blackAsset = PAA.Pixeltosh.Programs.Chess.Assets.TwoDimensional.King.Black

        @initialize()
    
    class @ThreeDimensional extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Chess.ThreeDimensional'
      @displayName: -> "3D"
      
      @unlockInstructions: -> "Complete the Elements of art: form task to start the 3D chess project."
      
      @contents: -> [
        @Pawn
        @Knight
        @Bishop
        @Rook
        @Queen
        @King
      ]
      
      @initialize()
      
      constructor: ->
        super arguments...
        
        @progress = new LM.Content.Progress.ContentProgress
          content: @
          units: "chess pieces"
      
      status: -> if false then LM.Content.Status.Unlocked else LM.Content.Status.Locked
      
      class @PieceType extends Chess.PieceType
        @project = PAA.Pixeltosh.Programs.Chess.Project.ThreeDimensional
        
      class @Pawn extends ThreeDimensional.PieceType
        @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Chess.ThreeDimensional.Pawn'
        
        @displayName: -> "Pawn"
        
        @whiteAsset = PAA.Pixeltosh.Programs.Chess.Assets.ThreeDimensional.Pawn.White
        @blackAsset = PAA.Pixeltosh.Programs.Chess.Assets.ThreeDimensional.Pawn.Black

        @initialize()
      
      class @Knight extends ThreeDimensional.PieceType
        @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Chess.ThreeDimensional.Knight'
        
        @displayName: -> "Knight"
        
        @whiteAsset = PAA.Pixeltosh.Programs.Chess.Assets.ThreeDimensional.Knight.White
        @blackAsset = PAA.Pixeltosh.Programs.Chess.Assets.ThreeDimensional.Knight.Black

        @initialize()
      
      class @Bishop extends ThreeDimensional.PieceType
        @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Chess.ThreeDimensional.Bishop'
        
        @displayName: -> "Bishop"
        
        @whiteAsset = PAA.Pixeltosh.Programs.Chess.Assets.ThreeDimensional.Bishop.White
        @blackAsset = PAA.Pixeltosh.Programs.Chess.Assets.ThreeDimensional.Bishop.Black

        @initialize()
      
      class @Rook extends ThreeDimensional.PieceType
        @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Chess.ThreeDimensional.Rook'
        
        @displayName: -> "Rook"
        
        @whiteAsset = PAA.Pixeltosh.Programs.Chess.Assets.ThreeDimensional.Rook.White
        @blackAsset = PAA.Pixeltosh.Programs.Chess.Assets.ThreeDimensional.Rook.Black

        @initialize()
      
      class @Queen extends ThreeDimensional.PieceType
        @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Chess.ThreeDimensional.Queen'
        
        @displayName: -> "Queen"
        
        @whiteAsset = PAA.Pixeltosh.Programs.Chess.Assets.ThreeDimensional.Queen.White
        @blackAsset = PAA.Pixeltosh.Programs.Chess.Assets.ThreeDimensional.Queen.Black

        @initialize()
      
      class @King extends ThreeDimensional.PieceType
        @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Chess.ThreeDimensional.King'
        
        @displayName: -> "King"
        
        @whiteAsset = PAA.Pixeltosh.Programs.Chess.Assets.ThreeDimensional.King.White
        @blackAsset = PAA.Pixeltosh.Programs.Chess.Assets.ThreeDimensional.King.Black

        @initialize()
  
  class @PixelPaint extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.PixelPaint'
    @displayName: -> "PixelPaint"
    @initialize()
  
  class @CityBuilder extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.CityBuilder'
    @displayName: -> "City builder"
    @initialize()
