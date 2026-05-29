PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.KnightJumps extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.KnightJumps'
  @displayName: -> "Knight jumps"

  @category: -> Chess.Lessons.Categories.Knight

  @steps: -> [
    @JumpOverPawns
    @End
  ]

  @startingPosition: ->
    d4: 'N'
    c5: 'p'
    d5: 'p'
    e5: 'p'

  @initialize()

  Lesson = @

  class @JumpOverPawns extends Chess.Lesson.Step
    @id: -> "#{Lesson.id()}.JumpOverPawns"

    @message: -> """
      The knight is the only piece that can leap over others. A wall of pawns can't stop it.

      Jump over the pawns to c6 or e6.
    """

    @initialize()

    completed: -> @positionAchieved(c6: 'N') or @positionAchieved(e6: 'N')
    
    failed: -> @positionAchieved(d4: null) and not @completed()
    
    @retryMessage: -> """
      Not quite the jump the knight was looking forward to.

      Move back and jump to c6 or e6.
    """

    markup: -> [
      arrows: [
        from: Chess.Square.d4
        to: Chess.Square.c6
      ,
        from: Chess.Square.d4
        to: Chess.Square.e6
      ]
    ]

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!

      No other piece could clear that wall—rooks, bishops, and queens all have to go around. The knight simply hops over anything in its way, friend or foe.
    """

    @initialize()
