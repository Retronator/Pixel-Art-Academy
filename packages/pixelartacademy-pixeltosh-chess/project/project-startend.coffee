AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Project extends Chess.Project
  @start: (properties = {}) ->
    super arguments...

    profileId = LOI.adventure.profileId()
    creationTime = new Date()
    
    # Create the chess set. Piece assets are added as the player unlocks them.
    projectId = PAA.Practice.Project.documents.insert _.extend {}, properties,
      startTime: creationTime
      lastEditTime: creationTime
      type: @id()
      profileId: profileId
      assets: []
    
    # Write the project ID into profile's game state.
    @state 'activeProjectId', projectId
