AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Pages.Admin.Memories.Components.ActionContent extends AM.Component
  @id: -> 'LandsOfIllusions.Pages.Admin.Memories.Components.ActionContent'
  @register @id()

  taskEntry: ->
    action = @currentData()
    action.content.taskEntry[0]

  taskName: ->
    taskEntry = @currentData()

    learningTaskClass = PixelArtAcademy.Learning.Task.getClassForId taskEntry.taskId
    learningTaskClass.directive()
