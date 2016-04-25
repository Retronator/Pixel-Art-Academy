LOI = LandsOfIllusions

Meteor.publish 'allSprites', ->
  LOI.Assets.Sprite.documents.find()
