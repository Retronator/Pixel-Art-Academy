AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Project extends Pinball.Project
  @start: ->
    # Make sure the player doesn't have an already active project.
    throw new AE.InvalidOperationException "Profile already has an active Pinball project." if Pinball.Project.state 'activeProjectId'

    new Promise (resolve, reject) =>
      Tracker.autorun (computation) =>
        LOI.Assets.Palette.forName.subscribeContent LOI.Assets.Palette.SystemPaletteNames.Macintosh
        return unless macintoshPalette = LOI.Assets.Palette.documents.findOne name: LOI.Assets.Palette.SystemPaletteNames.Macintosh
        computation.stop()

        # Create two pre-made sprites.
        profileId = LOI.adventure.profileId()
        creationTime = new Date()

        # Create the project.
        pixelSize = Pinball.CameraManager.orthographicPixelSize
        
        projectId = PAA.Practice.Project.documents.insert
          startTime: creationTime
          lastEditTime: creationTime
          type: Pinball.Project.id()
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
              
        # Write the project ID into profile's game state.
        Pinball.Project.state 'activeProjectId', projectId

        resolve()
