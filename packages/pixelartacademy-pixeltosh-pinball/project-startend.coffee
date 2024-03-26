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
              type: Pinball.Parts.BallSpawner.id()
              position:
                x: 173.5 * pixelSize
                z: 175.5 * pixelSize
            "#{Random.id()}":
              type: Pinball.Parts.Playfield.id()
              position:
                x: 90 * pixelSize
                z: 100 * pixelSize
            "#{Random.id()}":
              type: Pinball.Parts.Wall.id()
              position:
                x: 90 * pixelSize
                z: 100 * pixelSize
            "#{Random.id()}":
              type: Pinball.Parts.Plunger.id()
              position:
                x: 173.5 * pixelSize
                z: 189.5 * pixelSize
            "#{Random.id()}":
              type: Pinball.Parts.Flipper.id()
              position:
                x: 66.5 * pixelSize
                z: 176.5 * pixelSize
              maxAngleDegrees: 39.5
            "#{Random.id()}":
              type: Pinball.Parts.Flipper.id()
              position:
                x: 103.5 * pixelSize
                z: 176.5 * pixelSize
              flipped: true
              maxAngleDegrees: 39.5
            "#{Random.id()}":
              type: Pinball.Parts.GobbleHole.id()
              position:
                x: 85 * pixelSize
                z: 90 * pixelSize
              score: 1000
            "#{Random.id()}":
              type: Pinball.Parts.Trough.id()
              position:
                x: 85 * pixelSize
                z: 197 * pixelSize

        # Write the project ID into profile's game state.
        Pinball.Project.state 'activeProjectId', projectId

        resolve()
