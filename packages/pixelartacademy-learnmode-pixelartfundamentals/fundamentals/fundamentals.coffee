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
  ]

  @courses: -> [
    LM.PixelArtFundamentals.Fundamentals.Content.Course
  ]

  @initialize()

  constructor: ->
    super arguments...
    
    # Add intro goals to the Study Plan app.
    @_initializeStudyPlanAutorun = Tracker.autorun (computation) =>
      return unless LOI.adventure.gameState()
      return if PAA.PixelPad.Apps.StudyPlan.state 'goals'
      
      toDoTasksId = LM.Intro.Tutorial.Goals.ToDoTasks.id()
      pixelArtSoftwareId = LM.Intro.Tutorial.Goals.PixelArtSoftware.id()
      snakeId = LM.Intro.Tutorial.Goals.Snake.id()
      
      PAA.PixelPad.Apps.StudyPlan.state 'goals',
        "#{toDoTasksId}":
          connections: [
            goalId: pixelArtSoftwareId
            direction: PAA.PixelPad.Apps.StudyPlan.GoalConnectionDirections.Forward
          ]
        "#{pixelArtSoftwareId}":
          connections: [
            goalId: snakeId
            direction: PAA.PixelPad.Apps.StudyPlan.GoalConnectionDirections.Forward
          ]
        "#{snakeId}": {}
    
    # Create the pinball project when the application is enabled.
    @_createPinballProjectAutorun = Tracker.autorun (computation) =>
      return unless AM.Document.Persistence.profileReady()
      return unless LM.PixelArtFundamentals.pinballEnabled()
      return if PAA.Pixeltosh.Programs.Pinball.Project.state 'activeProjectId'
      
      PAA.Pixeltosh.Programs.Pinball.Project.start()

  destroy: ->
    super arguments...
    
    @_initializeStudyPlanAutorun.stop()
    @_createPinballProjectAutorun.stop()
