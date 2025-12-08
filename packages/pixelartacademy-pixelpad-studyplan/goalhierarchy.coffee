AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.GoalHierarchy
  constructor: (blueprint, goalsData) ->
    @goalNodesById = {}
    
    goalsDataById = {}
    goalsDataList = []
    
    for goalId, goalData of goalsData
      unless PAA.Learning.Goal.getClassForId goalId
        console.warn "Unrecognized goal present in the hierarchy.", goalId
        continue
        
      @goalNodesById[goalId] = blueprint.studyPlan.createGoalNode goalId, @

      goalData = _.extend {}, goalData, id: goalId
      goalsDataList.push goalData
      goalsDataById[goalId] = goalData
    
    # Root is the goal that no-one is connected to.
    rootGoalData = _.find goalsDataList, (goalData) =>
      incomingConnection = _.find goalsDataList, (otherGoalData) =>
        _.find otherGoalData.connections, (connection) => connection.goalId is goalData.id
      
      not incomingConnection
    
    # Recursively connect goal nodes.
    connect = (goalData) =>
      return unless goalData.connections
      goalNode = @goalNodesById[goalData.id]
      
      for connection in goalData.connections
        otherGoalData = goalsDataById[connection.goalId]
        otherGoalNode = @goalNodesById[otherGoalData.id]
        continue if otherGoalNode.parent
        
        otherGoalNode.parent = goalNode
        
        goalClass = PAA.Learning.Goal.getClassForId goalData.id
        
        if goalClass.isInterestProvidedFromIndividuallyCompletedFinalTask connection.interest
          connectingGoalNodes = goalNode.forwardGoalNodes
          
        else
          connectingGoalNodes = goalNode.sidewaysGoalNodes
        
        connectingGoalNodes.push otherGoalNode
        
        connect otherGoalData
    
    connect rootGoalData
    
    @rootGoalNode = @goalNodesById[rootGoalData.id]
    @rootGoalNode.calculateLocalPositions()
    @rootGoalNode.calculateGlobalPositions()

    console.log "hierarchy", @rootGoalNode
