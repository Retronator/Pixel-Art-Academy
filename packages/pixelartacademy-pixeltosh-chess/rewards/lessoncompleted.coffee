PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Rewards.LessonCompleted extends Chess.Reward
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Rewards.LessonCompleted'

  @displayName: -> "Lesson completed"

  @value: -> 2
  
  @initialize()
  
  onLessonCompleted: (completedCount) ->
    @reward() if completedCount is 1
