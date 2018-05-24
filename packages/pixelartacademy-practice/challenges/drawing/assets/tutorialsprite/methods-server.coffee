AE = Artificial.Everywhere
AB = Artificial.Base
PAA = PixelArtAcademy
LOI = LandsOfIllusions

PAA.Practice.Challenges.Drawing.TutorialSprite.create.method (characterId, tutorialId, assetId) ->
  check characterId, Match.DocumentId
  check tutorialId, String
  check assetId, String

  LOI.Authorize.characterAction characterId

  # Make sure the player doesn't have the sprite already.
  gameState = LOI.GameState.documents.findOne 'character._id': characterId
  throw new AE.InvalidOperationException "Game state was not found." unless gameState

  tutorialReadOnlyState = _.nestedProperty gameState.readOnlyState, "things.#{tutorialId}"
  assets = tutorialReadOnlyState?.assets or []

  asset = _.find assets, (asset) -> asset.id is assetId
  throw new AE.InvalidOperationException "Character already has this asset." if asset

  # Create the sprite.
  assetClass = PAA.Practice.Project.Asset.getClassForId assetId
  spriteId = assetClass.createSprite characterId

  PAA.Practice.Challenges.Drawing.TutorialSprite.reset assetId, spriteId

  # Add the asset.
  assets.push
    id: assetClass.id()
    type: assetClass.type()
    sprite: _id: spriteId

  # Update tutorial assets in the read-only state.
  LOI.GameState.documents.update gameState._id,
    $set:
      "readOnlyState.things.#{tutorialId}.assets": assets
