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
    @MusicTapes
    @Publications
    @Publications.Parts
    @Pico8Cartridges
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

    # Create the chess projects when the content is unlocked.
    @_createChess2DProjectAutorun = Tracker.autorun (computation) =>
      return unless AM.Document.Persistence.profileReady()
      return unless LM.PixelArtFundamentals.Fundamentals.Content.Projects.Chess.TwoDimensional.getAdventureInstance().status() is LM.Content.Status.Unlocked
      return if PAA.Pixeltosh.Programs.Chess.Project.TwoDimensional.state 'activeProjectId'
      
      PAA.Pixeltosh.Programs.Chess.Project.TwoDimensional.start()
  
  destroy: ->
    super arguments...
    
    @_createPinballProjectAutorun.stop()
    @_createChess2DProjectAutorun.stop()
