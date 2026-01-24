AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.Pathway
  constructor: (@startPoint, @endPoint, @goalNode) ->
    @localWaypointPositions = []
    @globalWaypointPositions = []
    
    # Don't add duplicate pathways.
    return @ if _.find @startPoint.outgoingPathways, (pathway) => pathway.endPoint is @endPoint
    
    @startPoint.outgoingPathways.push @
    @endPoint.incomingPathways.push @

  remove: ->
    _.pull @startPoint.outgoingPathways, @
    _.pull @endPoint.incomingPathways, @

  clone: (newStartPoint, newEndPoint, newGoalNode) ->
    pathway = new StudyPlan.Pathway newStartPoint, newEndPoint, newGoalNode
    pathway.localWaypointPositions.push @localWaypointPositions...
    pathway
  
  calculateGlobalPositions: (origin) ->
    @globalWaypointPositions = for localWaypointPosition in @localWaypointPositions
      localWaypointPosition.clone().add origin
