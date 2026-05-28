AE = Artificial.Everywhere
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lesson.PositionStep extends Chess.Lesson.Step
  @requiredPosition: -> throw new AE.NotImplementedException "Position step must define the position that needs to be reached for completion."
  @failedPosition: -> # Override if there is a fail state.

  completed: ->
    @positionAchieved @constructor.requiredPosition()
    
  failed: ->
    return unless failedPosition = @constructor.failedPosition()
    @positionAchieved failedPosition
