AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.ConnectionPoint
  @createLocal: (goalNode, x=0, y=0) ->
    connectionPoint = new @
    connectionPoint.goalNode = goalNode
    connectionPoint.localPosition.set x, y
    connectionPoint
    
  @createGlobal: (x, y) ->
    connectionPoint = new @
    connectionPoint.localPosition.set x, y
    connectionPoint.globalPosition.set x, y
    connectionPoint
    
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
