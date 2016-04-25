LOI = LandsOfIllusions

Meteor.methods
  'PixelArtAcademy.Pages.Intro.characterInitialize': (userId, characterId) ->
    check userId, Match.DocumentId
    check characterId, Match.Optional Match.DocumentId

    currentUserId = Meteor.userId()

    # Only the user itself can add a character.
    throw new Meteor.Error 'unauthorized', "Unauthorized." unless currentUserId is userId

    character =
      user:
        _id: userId
      name: ""

    character._id = characterId if characterId

    # Do demo initialization.
    pico8Palette = LOI.Assets.Palette.documents.findOne name: LOI.Assets.Palette.systemPaletteNames.pico8

    # First create two sprites.
    createSprite = (size, name) ->
      newId = Random.id()

      # Create a 16x16 sprite.
      Meteor.call 'spriteInsert', newId,
        name: name
        palette:
          name: LOI.Assets.Palette.systemPaletteNames.pico8
        bounds:
          left: 0
          right: size - 1
          top: 0
          bottom: size - 1

      newId

    character.currentDay = 0

    character.gameSprites = [
      [
        createSprite 8, 'snake'
        createSprite 8, 'food'
      ]
    ]

    # Create a green snake.
    snakePixels = []
    for x in [0..7]
      for y in [0..7]
        snakePixels.push
          x: x
          y: y
          colorIndex: 0
          relativeShade: 0

    Meteor.call 'spriteUpdate', character.gameSprites[0][0],
      $set:
        pixels: snakePixels
        palette:
          _id: pico8Palette._id
        colorMap:
          '0':
            name:'snake green'
            ramp: 3
            shade: 0

    # Create a brown food.
    foodPixels = []
    for x in [2..5]
      for y in [2..5]
        foodPixels.push
          x: x
          y: y
          colorIndex: 0
          relativeShade: 0

    Meteor.call 'spriteUpdate', character.gameSprites[0][1],
      $set:
        pixels: foodPixels
        palette:
          _id: pico8Palette._id
        colorMap:
          '0':
            name:'food brown'
            ramp: 4
            shade: 0

    LOI.Accounts.Character.documents.insert character
