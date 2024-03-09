LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals extends LM.Chapter
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals'
  
  @fullName: -> "Pixel art fundamentals"
  @number: -> 1
  
  @sections: -> []

  @scenes: -> [
    @Apps
    @TutorialsDrawing
    @ChallengesDrawing
    @PixeltoshPrograms
    @PixeltoshFiles
  ]

  @courses: -> [
    LM.PixelArtFundamentals.Fundamentals.Content.Course
  ]

  @initialize()
