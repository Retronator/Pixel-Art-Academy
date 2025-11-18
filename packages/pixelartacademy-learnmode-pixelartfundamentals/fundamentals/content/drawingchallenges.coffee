PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

PixelArtSoftware = PAA.Challenges.Drawing.PixelArtSoftware

class LM.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges extends LM.Content
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges'
  
  @displayName: -> "Drawing challenges"
  
  @contents: -> [
    @PixelArtLineArt
    @DrawQuickly
  ]
  
  @initialize()
  
  constructor: ->
    super arguments...
    
    @progress = new LM.Content.Progress.ContentProgress
      content: @
      weight: 3
      units: "challenges"

  status: -> @constructor.Status.Unlocked

  class @PixelArtLineArt extends LM.Content
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges.PixelArtLineArt'

    @displayName: -> "Pixel art line art"

    @contents: -> [
      @PixelPerfectLines
      @EvenDiagonals
      @SmoothCurves
      @ConsistentLineWidth
    ]

    @initialize()

    constructor: ->
      super arguments...
      
      @progress = new LM.Content.Progress.ContentProgress
        content: @
        units: "evaluation criteria"
  
    status: -> if PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.completed() then LM.Content.Status.Unlocked else LM.Content.Status.Locked
    
    @unlockInstructions: -> "Complete the Pixel art lines tutorial to unlock the Pixel art line art challenge."
    
    class @CompletedCriteria extends LM.Content
      @prefixFilter = null # Override with the class name prefix that defines this group.

      constructor: ->
        super arguments...

        @progress = new LM.Content.Progress.ManualProgress
          content: @

          completed: =>
            return unless unlockedPixelArtEvaluationCriteria = PAA.Practice.Project.Asset.Bitmap.state 'unlockedPixelArtEvaluationCriteria'
            @constructor.criterion() in unlockedPixelArtEvaluationCriteria

    class @PixelPerfectLines extends @CompletedCriteria
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges.PixelArtLineArt.PixelPerfectLines'

      @displayName: -> "Pixel-perfect lines"
      
      @unlockInstructions: -> "Complete the Pixel art lines tutorial to unlock Pixel-perfect lines evaluation."
      
      @initialize()

      @criterion: -> PAA.Practice.PixelArtEvaluation.Criteria.PixelPerfectLines

      status: -> LM.Content.Status.Unlocked
    
    class @EvenDiagonals extends @CompletedCriteria
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges.PixelArtLineArt.EvenDiagonals'
      
      @displayName: -> "Even diagonals"
      
      @unlockInstructions: -> "Complete the Pixel art diagonals tutorial to unlock Even diagonals evaluation."

      @initialize()
      
      @criterion: -> PAA.Practice.PixelArtEvaluation.Criteria.EvenDiagonals
      
      status: -> if PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.completed() then LM.Content.Status.Unlocked else LM.Content.Status.Locked
    
    class @SmoothCurves extends @CompletedCriteria
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges.PixelArtLineArt.SmoothCurves'
      
      @displayName: -> "Smooth curves"
      
      @unlockInstructions: -> "Complete the Pixel art curves tutorial to unlock Smooth curves evaluation."
      
      @initialize()
      
      @criterion: -> PAA.Practice.PixelArtEvaluation.Criteria.SmoothCurves
      
      status: -> if PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.completed() then LM.Content.Status.Unlocked else LM.Content.Status.Locked

    class @ConsistentLineWidth extends @CompletedCriteria
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges.PixelArtLineArt.ConsistentLineWidth'
      
      @displayName: -> "Consistent line width"
      
      @unlockInstructions: -> "Complete the Pixel art line width tutorial to unlock Consistent line width evaluation."
      
      @initialize()
      
      @criterion: -> PAA.Practice.PixelArtEvaluation.Criteria.ConsistentLineWidth
      
      status: -> if PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth.completed() then LM.Content.Status.Unlocked else LM.Content.Status.Locked
      
  class @DrawQuickly extends LM.Content
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges.DrawQuickly'
    @displayName: -> "Draw quickly"
    
    @unlockInstructions: -> "Complete the Simplification tutorial to unlock the Draw Quickly game on the Pixeltosh."
    
    @contents: -> [
      @SymbolicDrawing
      @RealisticDrawing
    ]
    
    @initialize()
    
    status: -> if LM.PixelArtFundamentals.drawQuicklyEnabled() then LM.Content.Status.Unlocked else LM.Content.Status.Locked
    
    constructor: ->
      super arguments...
      
      @progress = new LM.Content.Progress.ContentProgress
        content: @
        units: "modes"
        
    class @SymbolicDrawing extends LM.Content
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges.DrawQuickly.SymbolicDrawing'
      @displayName: -> "Symbolic drawing"
      
      @contents: -> [
        @Easy
        @Medium
        @Hard
      ]

      @initialize()

      status: -> LM.Content.Status.Unlocked

      constructor: ->
        super arguments...
      
        @progress = new LM.Content.Progress.ManualProgress
          content: @
          units: "combined score"
          
          completed: => @progress.completedUnitsCount() >= 1
          
          unitsCount: => 90
          
          completedUnitsCount: => _.sum (content.progress.completedUnitsCount() for content in @availableContents())
          
          requiredUnitsCount: => 1
          
      class @DifficultyLevel extends LM.Content
        constructor: ->
          super arguments...
          
          @progress = new LM.Content.Progress.ManualProgress
            content: @
            units: "combined score"
            
            completed: => @progress.completedUnitsCount() >= 1
            
            unitsCount: => 30
            
            completedUnitsCount: =>
              DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly
              SpeedProperties = DrawQuickly.SymbolicDrawing.SpeedProperties
              
              slowScore = DrawQuickly.SymbolicDrawing.getBestScoreForDifficultyAndSpeed @constructor.difficulty, SpeedProperties.Slow
              mediumScore = DrawQuickly.SymbolicDrawing.getBestScoreForDifficultyAndSpeed @constructor.difficulty, SpeedProperties.Medium
              fastScore = DrawQuickly.SymbolicDrawing.getBestScoreForDifficultyAndSpeed @constructor.difficulty, SpeedProperties.Fast
              
              # Faster times ripple back to slower times.
              mediumScore = Math.max mediumScore, fastScore
              slowScore = Math.max slowScore, mediumScore
              
              slowScore + mediumScore + fastScore
            
            requiredUnitsCount: => 1

        status: -> LM.Content.Status.Unlocked
  
      class @Easy extends @DifficultyLevel
        @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges.DrawQuickly.SymbolicDrawing.Easy'
        @displayName: -> "Easy"
        
        @difficulty = 'easy'
        
        @initialize()
        
      class @Medium extends @DifficultyLevel
        @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges.DrawQuickly.SymbolicDrawing.Medium'
        @displayName: -> "Medium"
        
        @difficulty = 'medium'
        
        @initialize()
      
      class @Hard extends @DifficultyLevel
        @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges.DrawQuickly.SymbolicDrawing.Hard'
        @displayName: -> "Hard"

        @difficulty = 'hard'

        @initialize()
    
    class @RealisticDrawing extends LM.Content
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges.DrawQuickly.RealisticDrawing'
      @displayName: -> "Realistic drawing"
      
      @contents: -> [
        @Simple
        @Medium
        @Complex
      ]
      
      @initialize()
      
      status: -> LM.Content.Status.Unlocked
      
      constructor: ->
        super arguments...
        
        @progress = new LM.Content.Progress.ManualProgress
          content: @
          units: "subjects"
          
          completed: => @progress.completedUnitsCount() >= 1
          
          unitsCount: => _.sum (content.progress.unitsCount() for content in @availableContents())
          
          completedUnitsCount: => _.sum (content.progress.completedUnitsCount() for content in @availableContents())
          
          requiredUnitsCount: => 1
      
      class @ComplexityLevel extends LM.Content
        constructor: ->
          super arguments...
          
          @progress = new LM.Content.Progress.ManualProgress
            content: @
            units: "subjects"
            
            completed: => @progress.completedUnitsCount() >= 1
            
            unitsCount: => PAA.Pixeltosh.Programs.DrawQuickly.RealisticDrawing.thingsByComplexity[@constructor.complexity].length
            
            completedUnitsCount: => PAA.Pixeltosh.Programs.DrawQuickly.RealisticDrawing.getDrawnThingsForComplexity(@constructor.complexity).length
            
            requiredUnitsCount: => 1
        
        status: -> LM.Content.Status.Unlocked
      
      class @Simple extends @ComplexityLevel
        @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges.DrawQuickly.RealisticDrawing.Simple'
        @displayName: -> "Simple"

        @complexity = 'simple'

        @initialize()
      
      class @Medium extends @ComplexityLevel
        @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges.DrawQuickly.RealisticDrawing.Medium'
        @displayName: -> "Medium"
        
        @complexity = 'medium'

        @initialize()
      
      class @Complex extends @ComplexityLevel
        @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges.DrawQuickly.RealisticDrawing.Complex'
        @displayName: -> "Complex"
        
        @complexity = 'complex'
        
        @initialize()
