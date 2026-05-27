PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lessons
  class @DefaultEndStep extends Chess.Lesson.EndStep
    @id: -> "PAA.Pixeltosh.Programs.Chess.Lessons.DefaultEndStep"
    
    @message: -> """
      Well done!
    """
    
    @initialize()
