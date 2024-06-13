LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Goals.ElementsOfArt extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.ElementsOfArt'

  @displayName: -> "Elements of art"
  
  @chapter: -> LM.PixelArtFundamentals.Fundamentals

  Goal = @

  class @Line extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.ElementsOfArt.Line'
    @goal: -> Goal

    @directive: -> "Learn about lines"

    @instructions: -> """
      In the Drawing app, complete the Elements of art: line tutorial to learn about the most foundational element of art.
    """

    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @interests: -> ['line']
  
    @initialize()
    
    @completedConditions: ->
      PAA.Tutorials.Drawing.ElementsOfArt.Line.completed()
      
    activeNotificationId: -> @constructor.Notification.id()
    
    Task = @
    
    class @Notification extends PAA.PixelPad.Systems.Notifications.Notification
      @id: -> "#{Task.id()}.Notification"
      
      @message: -> """
        There will be more elements of art added during Early Access.

        Until then, focus just on the lines.
        This will build your foundation before tackling harder elements such as values and colors.
      """
      
      @displayStyle: -> @DisplayStyles.IfIdle
      
      @initialize()
      
  @tasks: -> [
    @Line
  ]

  @finalTasks: -> [
    @Line
  ]

  @initialize()
