LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Tutorial.Goals.PixelArtSoftware extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware'

  @displayName: -> "Pixel art software"
  
  @chapter: -> LM.Intro.Tutorial

  Goal = @

  # Main path
  class @Basics extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware.Basics'
    @goal: -> Goal

    @directive: -> "Learn basic pixel art tools"

    @instructions: -> """
      In the Drawing app, complete the Basics tutorial to
      learn how to use essential drawing tools.
    """

    @icon: -> PAA.Learning.Task.Icons.Drawing
  
    @requiredInterests: -> ['to-do tasks']
    
    @studyPlanBuilding: -> 'SimCityResidential2'

    @initialize()
    
    @completedConditions: ->
      PAA.Tutorials.Drawing.PixelArtTools.Basics.completed()

  class @Helpers extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware.Helpers'
    @goal: -> Goal

    @directive: -> "Learn about helper tools"

    @instructions: -> """
      In the Drawing app, complete the Helpers
      tutorial to get used to extra tools such as zooming and drawing lines.
    """

    @icon: -> PAA.Learning.Task.Icons.Drawing

    @predecessors: -> [Goal.Basics]

    @groupNumber: -> -1
    
    @studyPlanBuilding: -> 'SimCityCommercial2'

    @initialize()

    @completedConditions: ->
      PAA.Tutorials.Drawing.PixelArtTools.Helpers.completed()

  class @ColorTools extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware.ColorTools'
    @goal: -> Goal

    @directive: -> "Learn about switching colors"

    @instructions: -> """
      In the Drawing app, complete the Colors
      tutorial to learn how to switch between different colors.
    """

    @icon: -> PAA.Learning.Task.Icons.Drawing

    @predecessors: -> [Goal.Basics]

    @groupNumber: -> 1
    
    @studyPlanBuilding: -> 'SimCityIndustrial3'

    @initialize()

    @completedConditions: ->
      PAA.Tutorials.Drawing.PixelArtTools.Colors.completed()

  class @CopyReference extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware.CopyReference'
    @goal: -> Goal

    @directive: -> "Complete the pixel art software challenge"

    @instructions: -> """
      In the Drawing app under the Challenges section, select a pixel art
      sprite and copy it to show you got the hang of using pixel art software.
    """

    @icon: -> PAA.Learning.Task.Icons.Drawing

    @interests: -> ['pixel art software', 'pixel art', 'drawing software']

    @predecessors: -> [Goal.Basics, Goal.Helpers, Goal.ColorTools]
    @predecessorsCompleteType: -> @PredecessorsCompleteType.Any
    
    @studyPlanBuilding: -> 'SimCityCommercial1'

    @initialize()

    @completedConditions: ->
      PAA.Challenges.Drawing.PixelArtSoftware.completed()
    
    activeNotificationId: -> @constructor.ActiveNotification.id()
    
    Task = @
    
    class @ActiveNotification extends PAA.PixelPad.Systems.Notifications.Notification
      @id: -> "#{Task.id()}.ActiveNotification"
      
      @message: -> """
        Note that you can complete to-do tasks in any order you want!
      """
      
      @displayStyle: -> @DisplayStyles.Always
      
      @initialize()

  @tasks: -> [
    @Basics
    @CopyReference
    @ColorTools
    @Helpers
  ]

  @finalTasks: -> [
    @CopyReference
  ]

  @initialize()
