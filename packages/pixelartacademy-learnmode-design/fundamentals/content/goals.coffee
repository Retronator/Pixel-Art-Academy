PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Design.Fundamentals.Content.Goals extends LM.Content
  @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Goals'

  @displayName: -> "Study goals"

  @contents: -> [
    @ShapeLanguage
    @Invasion
  ]

  @initialize()

  constructor: ->
    super arguments...

    @progress = new LM.Content.Progress.ContentProgress
      content: @
      weight: 2
      requiredUnits: "goals"
      totalUnits: "tasks"
      totalRecursive: true
  
  status: -> @constructor.Status.Unlocked

  class @ShapeLanguage extends LM.Content.GoalContent
    @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Goals.ShapeLanguage'
    @goalClass = LM.Design.Fundamentals.Goals.ShapeLanguage
    
    @unlockInstructions: -> "Complete the Elements of art: shape tutorial to unlock the Shape language study goal."
    
    @initialize()
  
    status: -> if LM.PixelArtFundamentals.Fundamentals.Goals.ElementsOfArt.Shape.completed() then LM.Content.Status.Unlocked else LM.Content.Status.Locked
    
  class @Invasion extends LM.Content.GoalContent
    @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Goals.Invasion'
    @goalClass = LM.Design.Fundamentals.Goals.Invasion
    
    @unlockInstructions: -> "Complete the Shape language tutorial to start working on the Invasion game."
    
    @initialize()
    
    constructor: ->
      super arguments...
  
      @progress = new LM.Content.Progress.ManualProgress
        content: @
        units: "sprites"
    
        completed: => @_goal()?.completed()

        requiredUnitsCount: 7

        requiredCompletedUnitsCount: =>
          taskClasses = [
            LM.Design.Fundamentals.Goals.Invasion.Start
            LM.Design.Fundamentals.Goals.Invasion.Run
            LM.Design.Fundamentals.Goals.Invasion.DrawDefender
            LM.Design.Fundamentals.Goals.Invasion.DrawDefenderProjectile
            LM.Design.Fundamentals.Goals.Invasion.DrawInvader
            LM.Design.Fundamentals.Goals.Invasion.DrawInvaderProjectile
            LM.Design.Fundamentals.Goals.Invasion.Play
          ]
          
          completedCount = 0

          for drawingTaskClass in taskClasses
            completedCount++ if drawingTaskClass.completed()
            
          completedCount
        
        unitsCount: => @_goal()?.tasks().length
        
        completedUnitsCount: => _.filter(@_goal()?.tasks(), (task) -> task.completed()).length
        
    status: -> if LM.Design.Fundamentals.Goals.ShapeLanguage.completed() then LM.Content.Status.Unlocked else LM.Content.Status.Locked
