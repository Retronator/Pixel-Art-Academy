AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.Blueprint.Goal.Task extends AM.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.StudyPlan.Blueprint.Goal.Task'
  @register @id()
  
  onCreated: ->
    super arguments...

    @goalComponent = @ancestorComponentOfType PAA.PixelPad.Apps.StudyPlan.Goal
    
  interestDocument: ->
    interest = @currentData()
    IL.Interest.find interest
