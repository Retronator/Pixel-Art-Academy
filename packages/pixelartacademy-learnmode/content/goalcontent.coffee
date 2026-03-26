AE = Artificial.Everywhere
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Content.GoalContent extends LM.Content
  @goalClass = null # Override to set which goal this content represents.

  @type: -> 'GoalContent'
  
  @displayName: -> null # The name will match the goal's name.

  @contents: -> @_contents
  
  @initialize: ->
    super arguments...
  
    @_contents = for taskClass in @goalClass.tasks()
      do (taskClass) =>
        id = "#{@goalClass.id()}-#{taskClass.id()}"
        class TaskClass extends LM.Content.TaskContent
          @taskClass = taskClass
          @id: -> id
  
        TaskClass.initialize()
        TaskClass
  
  _goal: -> PAA.Learning.Goal.getAdventureInstanceForId @constructor.goalClass.id()
  
  displayName: -> @_goal().displayName()
  displayNameTranslation: -> @_goal().displayNameTranslation()
  
  constructor: ->
    super arguments...

    @progress = new LM.Content.Progress.GoalProgress
      content: @
      goalClass: @constructor.goalClass
      totalUnits: "tasks"

  status: -> LM.Content.Status.Unlocked
  
  class LM.Content.TaskContent extends LM.Content
    @taskClass = null
    
    @type: -> 'TaskContent'
  
    @displayName: -> null # The name will match the task's directive.
    
    @tags: -> if @taskClass.completable() then [] else [LM.Content.Tags.Future]
  
    constructor: ->
      super arguments...
      
      @progress = new LM.Content.Progress.TaskProgress
        content: @
        taskClass: @constructor.taskClass
    
    status: -> if @constructor.taskClass.completable() then LM.Content.Status.Unlocked else LM.Content.Status.Unavailable
  
    _task: -> PAA.Learning.Task.getAdventureInstanceForId @constructor.taskClass.id()
  
    displayName: -> @_task().directive()
    displayNameTranslation: -> @_task().directiveTranslation()
