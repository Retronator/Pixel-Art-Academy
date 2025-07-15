AM = Artificial.Mummification
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
    @PixeltoshFiles
  ]

  @courses: -> [
    LM.Design.Fundamentals.Content.Course
  ]

  @initialize()
  
  constructor: ->
    super arguments...
    
    # Create the invasion project when it is enabled.
    @_createInvasionProjectAutorun = Tracker.autorun (computation) =>
      return unless AM.Document.Persistence.profileReady()
      return unless LM.Design.invasionEnabled()
      return if PAA.Pico8.Cartridges.Invasion.Project.state 'activeProjectId'
      
      PAA.Pico8.Cartridges.Invasion.Project.start()
  
  destroy: ->
    super arguments...
    
    @_createInvasionProjectAutorun.stop()
