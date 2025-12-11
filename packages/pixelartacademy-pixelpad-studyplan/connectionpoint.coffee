AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.ConnectionPoint
  constructor: ->
    @localPosition = new THREE.Vector2
    @globalPosition = new THREE.Vector2
    
    @requiredInterests = []
    @providedInterests = []
    
    @outgoingPathways = []
    @incomingPathways = []
  
  clone: ->
    taskPoint = new @constructor
    
    taskPoint.localPosition.copy @localPosition
    
    taskPoint.requiredInterests.push @requiredInterests...
    taskPoint.providedInterests.push @providedInterests...
    
    taskPoint

  calculateGlobalPosition: (origin) ->
    @globalPosition.copy(@localPosition).add origin
