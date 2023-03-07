AE = Artificial.Everywhere
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
SnakeProject = PAA.Pico8.Cartridges.Snake.Project

SnakeProject.start.method (profileId) ->
  check profileId, Match.DocumentId

  LOI.Authorize.profileAction profileId

  # Make sure the player doesn't have an already active project.
  gameState = LOI.GameState.documents.findOne 'profileId': profileId
  throw new AE.InvalidOperationException "Game state was not found." unless gameState

  projectReadOnlyState = _.nestedProperty gameState.readOnlyState, "things.#{SnakeProject.id()}"
  throw new AE.InvalidOperationException "Profile already has an active Snake project." if projectReadOnlyState?.activeProjectId

  pico8Palette = LOI.Assets.Palette.documents.findOne name: LOI.Assets.Palette.SystemPaletteNames.pico8

  # Create two pre-made sprites.
  createCommonSpriteData = ->
    creationTime: new Date()
    palette:
      _id: pico8Palette._id
    bounds:
      left: 0
      right: 7
      top: 0
      bottom: 7
      fixed: true
    authors: [
      _id: profileId
    ]

  # Create green snake body.
  snakePixels = []
  for x in [0..7]
    for y in [0..7]
      snakePixels.push
        x: x
        y: y
        paletteColor:
          ramp: 3
          shade: 0

  bodySpriteData = _.extend createCommonSpriteData(),
    name: SnakeProject.Body.displayName()
    layers: [
      pixels: snakePixels
    ]

  bodySpriteId = LOI.Assets.Sprite.documents.insert bodySpriteData

  # Create brown food.
  foodPixels = []
  for x in [2..5]
    for y in [2..5]
      foodPixels.push
        x: x
        y: y
        paletteColor:
          ramp: 4
          shade: 0

  foodSpriteData = _.extend createCommonSpriteData(),
    name: SnakeProject.Food.displayName()
    layers: [
      pixels: foodPixels
    ]

  foodSpriteId = LOI.Assets.Sprite.documents.insert foodSpriteData
  
  # Create the project.
  projectId = PAA.Practice.Project.documents.insert
    startTime: new Date()
    type: SnakeProject.id()
    profiles: [
      _id: profileId
    ]
    assets: [
      id: SnakeProject.Body.id()
      type: SnakeProject.Body.type()
      sprite:
        _id: bodySpriteId
    ,
      id: SnakeProject.Food.id()
      type: SnakeProject.Food.type()
      sprite:
        _id: foodSpriteId
    ]

  # Write the project ID into profile's read-only state.
  LOI.GameState.documents.update gameState._id,
    $set:
      "readOnlyState.things.#{SnakeProject.id()}.activeProjectId": projectId

SnakeProject.end.method (profileId) ->
  check profileId, Match.DocumentId

  LOI.Authorize.profileAction profileId

  # Make sure the player has an active project.
  gameState = LOI.GameState.documents.findOne 'profileId': profileId
  throw new AE.InvalidOperationException "Game state was not found." unless gameState

  projectReadOnlyState = _.nestedProperty gameState.readOnlyState, "things.#{SnakeProject.id()}"
  projectId = projectReadOnlyState?.activeProjectId
  throw new AE.InvalidOperationException "Profile does not have an active Snake project." unless projectId

  # End the project.
  projectId = PAA.Practice.Project.documents.update projectId,
    $set:
      endTime: new Date()

  # Remove project ID from profile's read-only state.
  LOI.GameState.documents.update gameState._id,
    $unset:
      "readOnlyState.things.#{SnakeProject.id()}.activeProjectId": true
