AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Adventure extends LOI.Adventure
  onCreated: ->
    super arguments...
    
    @_initializeInterests()
  
  _initializeInterests: ->
    @currentInterests = new ComputedField =>
      tasks = _.flatten (chapter.tasks for chapter in LOI.adventure.currentChapters())
      completedTasks = _.filter tasks, (task) => task.completed()
  
      _.union (task.interests() for task in completedTasks)...
