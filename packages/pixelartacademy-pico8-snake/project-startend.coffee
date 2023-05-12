AE = Artificial.Everywhere
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Snake = PAA.Pico8.Cartridges.Snake

class PAA.Pico8.Cartridges.Snake.Project extends PAA.Pico8.Cartridges.Snake.Project
  @start: ->
    # Make sure the player doesn't have an already active project.
    throw new AE.InvalidOperationException "Profile already has an active Snake project." if Snake.Project.state 'activeProjectId'

    new Promise (resolve, reject) =>
      Tracker.autorun (computation) =>
        LOI.Assets.Palette.forName.subscribeContent LOI.Assets.Palette.SystemPaletteNames.pico8
        return unless pico8Palette = LOI.Assets.Palette.documents.findOne name: LOI.Assets.Palette.SystemPaletteNames.pico8
        computation.stop()

        # Create two pre-made sprites.
        profileId = LOI.adventure.profileId()
        creationTime = new Date()
        pixelFormat = new LOI.Assets.Bitmap.PixelFormat 'flags', 'paletteColor'

        createCommonBitmapData = ->
          versioned: true
          profileId: profileId
          creationTime: creationTime
          lastEditTime: creationTime
          bounds:
            left: 0
            right: 7
            top: 0
            bottom: 7
            x: 0
            y: 0
            width: 8
            height: 8
            fixed: true
          pixelFormat: pixelFormat
          palette:
            _id: pico8Palette._id

        # Create green snake body.
        bodyBitmapData = createCommonBitmapData()
        bodyLayer = new LOI.Assets.Bitmap.Layer bodyBitmapData, bodyBitmapData, bounds: bodyBitmapData.bounds

        for x in [0..7]
          for y in [0..7]
            bodyLayer.setPixel x, y,
              paletteColor:
                ramp: 3
                shade: 0

        _.extend bodyBitmapData,
          name: Snake.Body.displayName()
          layers: [
            bodyLayer.toPlainObject()
          ]

        bodyBitmapId = LOI.Assets.Bitmap.documents.insert bodyBitmapData

        # Create brown food.
        foodBitmapData = createCommonBitmapData()
        foodLayer = new LOI.Assets.Bitmap.Layer foodBitmapData, foodBitmapData, bounds: foodBitmapData.bounds
        for x in [2..5]
          for y in [2..5]
            foodLayer.setPixel x, y,
              paletteColor:
                ramp: 4
                shade: 0

        _.extend foodBitmapData,
          name: Snake.Food.displayName()
          layers: [
            foodLayer.toPlainObject()
          ]

        foodBitmapId = LOI.Assets.Bitmap.documents.insert foodBitmapData

        # Create the project.
        projectId = PAA.Practice.Project.documents.insert
          startTime: creationTime
          lastEditTime: creationTime
          type: Snake.Project.id()
          profileId: profileId
          assets: [
            id: Snake.Body.id()
            type: Snake.Body.type()
            bitmapId: bodyBitmapId
          ,
            id: Snake.Food.id()
            type: Snake.Food.type()
            bitmapId: foodBitmapId
          ]

        # Write the project ID into profile's game state.
        Snake.Project.state 'activeProjectId', projectId

        resolve()

  @end: ->
    # Make sure the player has an active project.
    projectId = Snake.Project.state 'activeProjectId'
    throw new AE.InvalidOperationException "Profile does not have an active Snake project." unless projectId

    # End the project.
    endTime = new Date()
    projectId = PAA.Practice.Project.documents.update projectId,
      $set:
        endTime: endTime
        lastEditTime: endTime

    # Remove project ID from profile's game state.
    Snake.Project.state 'activeProjectId', null
