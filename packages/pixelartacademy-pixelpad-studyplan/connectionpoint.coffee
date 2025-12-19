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
    connectionPoint = new @constructor
    
    connectionPoint.localPosition.copy @localPosition
    
    connectionPoint.requiredInterests.push @requiredInterests...
    connectionPoint.providedInterests.push @providedInterests...
    
    connectionPoint

  calculateGlobalPosition: (origin) ->
    @globalPosition.copy(@localPosition).add origin
  
  propagateInterests: ->
    @propagatedProvidedInterests = []
    
    # To propagate interests we add all propagated interests from incoming pathways and add our own provided interests.
    for pathway in @incomingPathways
      pathway.startPoint.propagateInterests() unless pathway.startPoint.propagatedProvidedInterests
      @propagatedProvidedInterests.push interest for interest in pathway.startPoint.propagatedProvidedInterests when interest not in @propagatedProvidedInterests
      
    @propagatedProvidedInterests.push interest for interest in @providedInterests when interest not in @propagatedProvidedInterests
    
    # Propagate forward to all outgoing pathways.
    for pathway in @outgoingPathways
      pathway.endPoint.propagateInterests()
