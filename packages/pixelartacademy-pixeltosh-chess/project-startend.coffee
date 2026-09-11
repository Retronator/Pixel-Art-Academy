AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Project extends Chess.Project
  @start: ->
    super arguments...

    profileId = LOI.adventure.profileId()
    creationTime = new Date()
    
    # Create the project with the six standard piece types.
    projectId = PAA.Practice.Project.documents.insert
      startTime: creationTime
      lastEditTime: creationTime
      type: @id()
      profileId: profileId
      assets: []
    
    # Write the project ID into profile's game state.
    @state 'activeProjectId', projectId
