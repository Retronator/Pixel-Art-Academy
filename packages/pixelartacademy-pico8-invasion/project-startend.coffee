AE = Artificial.Everywhere
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Invasion = PAA.Pico8.Cartridges.Invasion

class PAA.Pico8.Cartridges.Invasion.Project extends PAA.Pico8.Cartridges.Invasion.Project
  @start: ->
    # Make sure the player doesn't have an already active project.
    throw new AE.InvalidOperationException "Profile already has an active Invasion project." if Invasion.Project.state 'activeProjectId'
    
    profileId = LOI.adventure.profileId()
    creationTime = new Date()
    
    # Create the project.
    projectId = PAA.Practice.Project.documents.insert
      startTime: creationTime
      lastEditTime: creationTime
      type: PAA.Pico8.Cartridges.Invasion.Project.id()
      profileId: profileId
      assets: []
      design:
        entities: []
      designDocument:
        writtenUnits: []
    
    # Write the project ID into profile's game state.
    Invasion.Project.state 'activeProjectId', projectId
  
  @end: ->
    # Make sure the player has an active project.
    projectId = Invasion.Project.state 'activeProjectId'
    throw new AE.InvalidOperationException "Profile does not have an active Invasion project." unless projectId

    # End the project.
    endTime = new Date()
    projectId = PAA.Practice.Project.documents.update projectId,
      $set:
        endTime: endTime
        lastEditTime: endTime

    # Remove project ID from profile's game state.
    Invasion.Project.state 'activeProjectId', null
