AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

class PAA.PixelBoy.Apps.StudyPlan.Goal.Task extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.StudyPlan.Goal.Task'
  @register @id()
  
  onCreated: ->
    super
    
  interestDocument: ->
    interest = @currentData()
    IL.Interest.find interest
