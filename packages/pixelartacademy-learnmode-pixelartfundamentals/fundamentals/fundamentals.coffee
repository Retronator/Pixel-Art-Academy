AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals extends LM.Chapter
  # openedPinballMachine: boolean whether the player has opened the Pinball Machine file.
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
    @Workbench
  ]

  @courses: -> [
    LM.PixelArtFundamentals.Fundamentals.Content.Course
  ]

  @initialize()

  constructor: ->
    super arguments...
    
    # Create the pinball project when the application is enabled.
    @_createPinballProjectAutorun = Tracker.autorun (computation) =>
      return unless AM.Document.Persistence.profileReady()
      return unless LM.PixelArtFundamentals.pinballEnabled()
      return if PAA.Pixeltosh.Programs.Pinball.Project.state 'activeProjectId'
      
      PAA.Pixeltosh.Programs.Pinball.Project.start()

  destroy: ->
    super arguments...
    
    @_createPinballProjectAutorun.stop()
