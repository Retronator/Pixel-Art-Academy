AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Project extends Pinball.Project
  @initialize()
  
  @start: ->
    super arguments...

    profileId = LOI.adventure.profileId()
    creationTime = new Date()

    # Create the project.
    pixelSize = Pinball.CameraManager.orthographicPixelSize
    
    projectId = PAA.Practice.Project.documents.insert
      startTime: creationTime
      lastEditTime: creationTime
      type: @id()
      profileId: profileId
      assets: []
      playfield:
        "#{Random.id()}":
          type: Pinball.Parts.Playfield.id()
          position:
            x: 90 * pixelSize
            z: 100 * pixelSize
        "#{Random.id()}":
          type: Pinball.Parts.Walls.id()
          position:
            x: 90 * pixelSize
            z: 100 * pixelSize
        "#{Random.id()}":
          type: Pinball.Parts.WireBallGuides.id()
          position:
            x: 90 * pixelSize
            z: 100 * pixelSize
        "#{Random.id()}":
          type: Pinball.Parts.Pins.id()
          position:
            x: 90 * pixelSize
            z: 100 * pixelSize
        "#{Random.id()}":
          type: Pinball.Parts.BallSpawner.id()
          position:
            x: 173.5 * pixelSize
            z: 156.5 * pixelSize
        "#{Random.id()}":
          type: Pinball.Parts.Plunger.id()
          position:
            x: 173.5 * pixelSize
            z: 189.5 * pixelSize
    
    # Write the project ID into profile's game state.
    @state 'activeProjectId', projectId
