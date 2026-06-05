PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons.PawnChains extends Chess.Lesson
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lessons.PawnChains'
  @displayName: -> "Pawn chains"

  @category: -> Chess.Lessons.Categories.Pawn

  @steps: -> [
    @BuildChain
    @RecaptureHead
    @End
  ]

  @startingPosition: ->
    d3: 'P'
    e3: 'P'
    d5: 'p'

  @initialize()

  aiMove: -> @randomAICapture() or @randomAIMove()

  Lesson = @

  class @BuildChain extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.BuildChain"

    @message: -> """
      Your pawns can link into a chain along a diagonal. They'll be able to take a hit and survive.

      Push from e3 to e4 and offer Black the capture.
    """

    @requiredPosition: ->
      e4: 'P'

    @failedPosition: ->
      d4: 'P'
    
    @retryMessage: -> """
      That locks the d-file and prevents a protected push to e4.

      We want Black to attack the head of the chain, so the base can answer.
      
      Let's rewind: push e3 to e4 instead.
    """

    @initialize()

  class @RecaptureHead extends Chess.Lesson.PositionStep
    @id: -> "#{Lesson.id()}.RecaptureHead"

    @message: -> """
      Black captured your head pawn, but your base is defending it. Take it back.

      Recapture on e4.
    """

    @requiredPosition: ->
      d3: null
      d4: null
      
    @failedPosition: ->
      d4: 'P'
    
    @retryMessage: -> """
      You let the pawn escape.
      
      Let's try again: capture on e4.
    """

    @initialize()

  class @End extends Chess.Lesson.EndStep
    @id: -> "#{Lesson.id()}.End"

    @message: -> """
      Well done!

      Pawns defend each other diagonally, linking into chains of any length, each guarding the one ahead. Only the base goes undefended.
    """

    @initialize()
