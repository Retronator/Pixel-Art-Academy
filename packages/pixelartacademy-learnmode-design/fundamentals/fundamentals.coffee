LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Design.Fundamentals extends LM.Chapter
  @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals'
  
  @fullName: -> "Shape"
  @number: -> 1
  
  @sections: -> []
  
  @scenes: -> [
    @TutorialsDrawing
  ]

  @courses: -> [
    LM.Design.Fundamentals.Content.Course
  ]

  @initialize()
