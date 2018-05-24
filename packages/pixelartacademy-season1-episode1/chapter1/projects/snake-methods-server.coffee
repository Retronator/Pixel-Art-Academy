AE = Artificial.Everywhere
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
Snake = C1.Projects.Snake

Snake.start.method (characterId) ->
  check characterId, Match.DocumentId

  LOI.Authorize.characterAction characterId

  # Make sure the player doesn't have an already active project.
  gameState = LOI.GameState.documents.findOne 'character._id': characterId
  throw new AE.InvalidOperationException "Game state was not found." unless gameState

  projectReadOnlyState = _.nestedProperty gameState.readOnlyState, "things.#{Snake.id()}"
  throw new AE.InvalidOperationException "Character already has an active Snake project." if projectReadOnlyState?.activeProjectId

  pico8Palette = LOI.Assets.Palette.documents.findOne name: LOI.Assets.Palette.SystemPaletteNames.pico8

  # Create two pre-made sprites.
  createCommonSpriteData = ->
    palette:
      _id: pico8Palette._id
    bounds:
      left: 0
      right: 7
      top: 0
      bottom: 7
      fixed: true
    authors: [
      _id: characterId
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
    name: Snake.Body.displayName()
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
    name: Snake.Food.displayName()
    layers: [
      pixels: foodPixels
    ]

  foodSpriteId = LOI.Assets.Sprite.documents.insert foodSpriteData
  
  # Create the project.
  projectId = PAA.Practice.Project.documents.insert
    startTime: new Date()
    type: Snake.id()
    characters: [
      _id: characterId
    ]
    assets: [
      id: Snake.Body.id()
      type: Snake.Body.type()
      sprite:
        _id: bodySpriteId
    ,
      id: Snake.Food.id()
      type: Snake.Food.type()
      sprite:
        _id: foodSpriteId
    ]

  # Write the project ID into character's read-only state.
  LOI.GameState.documents.update gameState._id,
    $set:
      "readOnlyState.things.#{Snake.id()}.activeProjectId": projectId

Snake.end.method (characterId) ->
  check characterId, Match.DocumentId

  LOI.Authorize.characterAction characterId

  # Make sure the player has an active project.
  gameState = LOI.GameState.documents.findOne 'character._id': characterId
  throw new AE.InvalidOperationException "Game state was not found." unless gameState

  projectReadOnlyState = _.nestedProperty gameState.readOnlyState, "things.#{Snake.id()}"
  projectId = projectReadOnlyState?.activeProjectId
  throw new AE.InvalidOperationException "Character does not have an active Snake project." unless projectId

  # End the project.
  projectId = PAA.Practice.Project.documents.update projectId,
    $set:
      endTime: new Date()

  # Remove project ID from character's read-only state.
  LOI.GameState.documents.update gameState._id,
    $unset:
      "readOnlyState.things.#{Snake.id()}.activeProjectId": true
