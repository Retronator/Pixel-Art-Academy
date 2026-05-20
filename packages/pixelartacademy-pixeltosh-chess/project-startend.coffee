AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Project extends Chess.Project
  @start2D: ->
    # Make sure the player doesn't have an already active project.
    throw new AE.InvalidOperationException "Profile already has an active Chess 2D project." if Chess.Project.TwoDimensional.state 'activeProjectId'

    profileId = LOI.adventure.profileId()
    creationTime = new Date()
    
    # Create the project with the six standard piece types.
    projectId = PAA.Practice.Project.documents.insert
      startTime: creationTime
      lastEditTime: creationTime
      type: Chess.Project.TwoDimensional.id()
      profileId: profileId
      assets: []
    
    # Write the project ID into profile's game state.
    Chess.Project.TwoDimensional.state 'activeProjectId', projectId
  
  @end2D: ->
    # Make sure the player has an active project.
    projectId = Chess.Project.state 'activeProjectId'
    throw new AE.InvalidOperationException "Profile does not have an active Chess 2D project." unless projectId
    
    # End the project.
    endTime = new Date()
    PAA.Practice.Project.documents.update projectId,
      $set:
        endTime: endTime
        lastEditTime: endTime
    
    # Remove project ID from profile's game state.
    Chess.Project.TwoDimensional.state 'activeProjectId', null
