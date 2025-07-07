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
    @Workbench
    @Pico8Cartridges
  ]

  @courses: -> [
    LM.Design.Fundamentals.Content.Course
  ]

  @initialize()
