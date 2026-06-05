PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.OpeningTheFile extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.OpeningTheFile'
  @displayName: -> "Opening the file"

  @category: -> Chess.Lessons.Categories.Rook

  @steps: -> [
    @CaptureBlocker
    @ReachTarget
    @End
  ]

  @startingPosition: ->
    d2: 'R'
    d4: 'P'
    e5: 'p'
    f6: 'p'

  @initialize()
  
  aiMove: -> @randomAICapture() or @randomAIMove()

  Lesson = @

  class @CaptureBlocker extends Chess.Lesson.Step
    @id: -> "#{Lesson.id()}.CaptureBlocker"
    
    @message: -> """
      How do you get to the target in the fewest moves?

      Open the file (column) by capturing the pawn.
    """
    
    completed: -> @positionAchieved e5: 'P'
    
    failed: -> @positionAchieved(d5: 'P') or @positionAchieved(d2: null)
    
    @retryMessage: -> """
      It will take you longer to get to the target this way.

      Trading your pawn clears the way for the rook's powerful reach.

      Take on e5.
    """
    
    @initialize()
    
    markup: -> [
      target:
        position: Chess.Square.d8
    ]

  class @ReachTarget extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.ReachTarget"

    @message: -> """
      The file is clear.

      Reach d8.
    """

    @requiredPosition: ->
      d8: 'R'

    @initialize()
    
    markup: -> [
      target:
        position: Chess.Square.d8
    ]

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!

      An open file is a rook's highway. A rook placed on one controls the board from edge to edge.
    """

    @initialize()
