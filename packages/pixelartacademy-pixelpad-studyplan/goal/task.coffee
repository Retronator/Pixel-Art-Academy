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
  
  buildingStyle: ->
    height = 10 + Math.floor Math.random() * 10
    height-- if height in [12, 16]
    height++ if height in [13, 17]
    
    width: "13rem"
    height: "#{height}rem"
    top: "#{5 - height}rem"
    
  gateClass: ->
    task = @data()
    
    'gate' if task.requiredInterests().length
