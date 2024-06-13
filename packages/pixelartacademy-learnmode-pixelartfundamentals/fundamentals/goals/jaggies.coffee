LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Goals.Jaggies extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Jaggies'

  @displayName: -> "Pixel art fundamentals: jaggies"
  
  @chapter: -> LM.PixelArtFundamentals.Fundamentals

  Goal = @

  class @Lines extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Jaggies.Lines'
    @goal: -> Goal

    @directive: -> "Learn about lines in pixel art"

    @instructions: -> """
      In the Drawing app, complete the Pixel art lines tutorial to learn about jaggies.
    """
    
    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @requiredInterests: -> ['line']
    
    @interests: -> ['jaggy']
    
    @initialize()
    
    @completedConditions: ->
      PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.completed()
  
  class @Diagonals extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Jaggies.Diagonals'
    @goal: -> Goal
    
    @directive: -> "Learn about diagonals in pixel art"
    
    @instructions: -> """
      In the Drawing app, complete the Pixel art diagonals tutorial to learn about how different angles affect the patterns of jaggies.
    """
    
    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @predecessors: -> [Goal.Lines]
    
    @groupNumber: -> 1
    
    @initialize()
    
    @completedConditions: ->
      PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.completed()
  
  class @Curves extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Jaggies.Curves'
    @goal: -> Goal
    
    @directive: -> "Learn about curves in pixel art"
    
    @instructions: -> """
      In the Drawing app, complete the Pixel art curves tutorial to learn what makes lines appear smooth.
    """
    
    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @predecessors: -> [Goal.Lines]
    
    @groupNumber: -> 2
    
    @initialize()
    
    @completedConditions: ->
      PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.completed()
      
  class @LineWidth extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Jaggies.LineWidth'
    @goal: -> Goal
    
    @directive: -> "Learn about line width in pixel art"
    
    @instructions: -> """
      In the Drawing app, complete the Pixel art line width tutorial to learn how you can achieve different line thicknesses.
    """
    
    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @predecessors: -> [Goal.Lines]
    
    @groupNumber: -> 3
    
    @initialize()
    
    @completedConditions: ->
      PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth.completed()
  
  class @PixelPerfectLines extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Jaggies.PixelPerfectLines'
    @goal: -> Goal
    
    @directive: -> "Draw a sprite with pixel-perfect lines"
    
    @instructions: -> """
      In the Drawing app, choose a reference in the Pixel art line art challenge.
      Complete the drawing, enable the Pixel-perfect lines criterion in the pixel art evaluation paper, and achieve a score of 80% or more (keep both doubles and corners as required).
    """
    
    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @interests: -> ['pixel-perfect line']
    
    @predecessors: -> [Goal.Lines]
    
    @initialize()
    
    @completedConditions: ->
      PAA.Challenges.Drawing.PixelArtLineArt.completedPixelPerfectLines()
  
    activeNotificationId: -> Goal.WIPNotification.id()
  
  class @EvenDiagonals extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Jaggies.EvenDiagonals'
    @goal: -> Goal
    
    @directive: -> "Draw a sprite with even diagonals"
    
    @instructions: -> """
      In the Drawing app, choose a reference in the Pixel art line art challenge.
      Complete the drawing, enable the Even diagonals criterion in the pixel art evaluation paper, and achieve a score of 80% or more while having at least 10 lines with even segment lengths.
    """
    
    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @interests: -> ['even diagonal (pixel art)']
    
    @predecessors: -> [Goal.Diagonals]
    
    @groupNumber: -> 1
    
    @initialize()
    
    @completedConditions: ->
      PAA.Challenges.Drawing.PixelArtLineArt.completedEvenDiagonals()
  
    activeNotificationId: -> Goal.WIPNotification.id()

  class @SmoothCurves extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Jaggies.SmoothCurves'
    @goal: -> Goal
    
    @directive: -> "Draw a sprite with smooth curves"
    
    @instructions: -> """
      In the Drawing app, choose a reference in the Pixel art line art challenge.
      Complete the drawing, enable the Smooth curves criterion in the pixel art evaluation paper, and achieve a score of 80% or more (both in total and individually for abrupt length changes, straight parts, and inflection points).
    """
    
    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @interests: -> ['smooth curve (pixel art)']
    
    @predecessors: -> [Goal.Curves]
    
    @groupNumber: -> 2
    
    @initialize()
    
    @completedConditions: ->
      PAA.Challenges.Drawing.PixelArtLineArt.completedSmoothCurves()
  
    activeNotificationId: -> Goal.WIPNotification.id()
  
  class @ConsistentLineWidth extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Jaggies.ConsistentLineWidth'
    @goal: -> Goal
    
    @directive: -> "Draw a sprite with a consistent line width style"
    
    @instructions: -> """
      In the Drawing app, choose a reference in the Pixel art line art challenge.
      Complete the drawing, enable the Consistent line width criterion in the pixel art evaluation paper, and achieve a score of 80% or more for either individual line width consistency or for having a uniform line width type.
    """
    
    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @interests: -> ['line width (pixel art)']
    
    @predecessors: -> [Goal.LineWidth]
    
    @groupNumber: -> 3
    
    @initialize()
    
    @completedConditions: ->
      PAA.Challenges.Drawing.PixelArtLineArt.completedConsistentLineWidth()
    
    activeNotificationId: -> Goal.WIPNotification.id()
  
  @tasks: -> [
    @Lines
    @Diagonals
    @Curves
    @LineWidth
    @PixelPerfectLines
    @EvenDiagonals
    @SmoothCurves
    @ConsistentLineWidth
  ]

  @finalTasks: -> [
    @PixelPerfectLines
    @EvenDiagonals
    @SmoothCurves
    @ConsistentLineWidth
  ]

  @initialize()
  
  class @WIPNotification extends PAA.PixelPad.Systems.Notifications.Notification
    @id: -> "#{Goal.id()}.WIPNotification"
    
    @message: -> """
      Pixel art evaluation is being continually improved and is a bit of an experimental feature.
      
      Don't take its scores too seriously and trust your artistic judgment over directly following it.
    """
    
    @displayStyle: -> @DisplayStyles.Always
    
    @retroClasses: ->
      head: PAA.PixelPad.Systems.Notifications.Retro.HeadClasses.HardHat
      body: PAA.PixelPad.Systems.Notifications.Retro.BodyClasses.Wrench
    
    @retroClassesDisplayed: ->
      head: PAA.PixelPad.Systems.Notifications.Retro.HeadClasses.HardHatPuffed
      face: PAA.PixelPad.Systems.Notifications.Retro.FaceClasses.Yikes
    
    @initialize()
