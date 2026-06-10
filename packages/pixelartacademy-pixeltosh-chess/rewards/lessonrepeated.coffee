PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Rewards.LessonRepeated extends Chess.Reward
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Rewards.LessonRepeated'

  @displayName: -> "Lesson repeated"

  @value: -> 1
  
  @initialize()
  
  onLessonCompleted: (completedCount) ->
    @reward() if completedCount is 2
