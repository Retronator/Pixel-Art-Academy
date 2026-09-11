AE = Artificial.Everywhere
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Invasion = PAA.Pico8.Cartridges.Invasion

class PAA.Pico8.Cartridges.Invasion.Project extends PAA.Pico8.Cartridges.Invasion.Project
  @start: ->
    super arguments...
    
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
