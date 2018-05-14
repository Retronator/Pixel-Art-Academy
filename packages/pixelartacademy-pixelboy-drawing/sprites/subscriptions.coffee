LOI = LandsOfIllusions

Meteor.publish 'allSprites', ->
  LOI.Assets.Sprite.documents.find()

Meteor.publish 'characterGameSprites', (characterId) ->
  character = LOI.Character.documents.findOne characterId
  return unless character and character.currentDay

  # Gather sprite IDs for desired days.
  spriteIds = []

  for i in [0..character.currentDay]
    spriteIds = spriteIds.concat character.gameSprites[i]

  console.log 'spriteIds', spriteIds

  LOI.Assets.Sprite.documents.find
    _id:
      $in: spriteIds
