AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.Pathway
  constructor: (@startPoint, @endPoint, @interest = null) ->
    @localWaypointPositions = []
    @globalWaypointPositions = []
    
    @startPoint.outgoingPathways.push @
    @endPoint.incomingPathways.push @

  clone: (newStartPoint, newEndPoint) ->
    pathway = new StudyPlan.Pathway newStartPoint, newEndPoint, @interest
    pathway.localWaypointPositions.push @localWaypointPositions...
    pathway
