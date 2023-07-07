AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

class PAA.PixelPad.Apps.StudyPlan.Goal.Task extends AM.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.StudyPlan.Goal.Task'
  @register @id()
  
  onCreated: ->
    super arguments...

    @goalComponent = @ancestorComponentOfType PAA.PixelPad.Apps.StudyPlan.Goal
    
  interestDocument: ->
    interest = @currentData()
    IL.Interest.find interest

  activeClass: ->
    task = @data()

    'active' if task.active()
