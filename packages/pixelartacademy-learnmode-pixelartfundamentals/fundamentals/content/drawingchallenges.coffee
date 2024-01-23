PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

PixelArtSoftware = PAA.Challenges.Drawing.PixelArtSoftware

class LM.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges extends LM.Content
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges'
  
  @displayName: -> "Drawing challenges"
  
  @contents: -> [
    @PixelArtLineArt
    @AntiAliasing
    @DitheredValues
    @DitheredColors
  ]
  
  @tags: -> [LM.Content.Tags.WIP]
  
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
    
    @tags: -> [LM.Content.Tags.WIP]

    @initialize()

    constructor: ->
      super arguments...
      
      @progress = new LM.Content.Progress.ContentProgress
        content: @
        units: "evaluation criteria"
  
    status: -> if PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.completed() then LM.Content.Status.Unlocked else LM.Content.Status.Locked

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
      
      @initialize()

      @criterion: -> PAA.Practice.PixelArtEvaluation.Criteria.PixelPerfectLines

      status: -> LM.Content.Status.Unlocked
    
    class @EvenDiagonals extends @CompletedCriteria
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges.PixelArtLineArt.EvenDiagonals'
      
      @displayName: -> "Even diagonals"
      
      @initialize()
      
      @criterion: -> PAA.Practice.PixelArtEvaluation.Criteria.EvenDiagonals
      
      status: -> if PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.completed() then LM.Content.Status.Unlocked else LM.Content.Status.Locked
    
    class @SmoothCurves extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges.PixelArtLineArt.SmoothCurves'
      
      @displayName: -> "Smooth curves"
      
      @initialize()
      
      @criterion: -> PAA.Practice.PixelArtEvaluation.Criteria.SmoothCurves
    
    class @ConsistentLineWidth extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges.PixelArtLineArt.ConsistentLineWidth'
      
      @displayName: -> "Consistent line width"
      
      @initialize()
      
      @criterion: -> PAA.Practice.PixelArtEvaluation.Criteria.ConsistentLineWidth
      
  class @AntiAliasing extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges.AntiAliasing'
    @displayName: -> "Anti-aliasing"
    @initialize()
  
  class @DitheredValues extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges.DitheredValues'
    @displayName: -> "Dithered values"
    @initialize()
  
  class @DitheredColors extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges.DitheredColors'
    @displayName: -> "Dithered colors"
    @initialize()
