AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.Pathway
  constructor: (@startPoint, @endPoint, @interest = null) ->
    @localWaypointPositions = []
    @globalWaypointPositions = []
    
    # Don't add duplicate pathways.
    return @ if _.find @startPoint.outgoingPathways, (pathway) => pathway.endPoint is @endPoint and pathway.interest is @interest
    
    @startPoint.outgoingPathways.push @
    @endPoint.incomingPathways.push @

  clone: (newStartPoint, newEndPoint) ->
    pathway = new StudyPlan.Pathway newStartPoint, newEndPoint, @interest
    pathway.localWaypointPositions.push @localWaypointPositions...
    pathway
  
  calculateGlobalPositions: (origin) ->
    @globalWaypointPositions = for localWaypointPosition in @localWaypointPositions
      localWaypointPosition.clone().add origin
