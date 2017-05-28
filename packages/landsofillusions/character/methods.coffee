AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Character.insert.method ->
  user = Retronator.requireUser()

  # User must be a player.
  LOI.Authorize.player()

  # Create a character that will belong to the user executing this method.
  character =
    user:
      _id: user._id

  LOI.Character.documents.insert character

LOI.Character.updateColor.method (characterId, hue, shade) ->
  check characterId, Match.DocumentId
  check hue, Match.OptionalOrNull Match.Integer
  check shade, Match.OptionalOrNull Match.Integer

  LOI.Authorize.player()
  LOI.Authorize.characterAction characterId

  set = {}
  set['avatar.color.hue'] = hue if hue?
  set['avatar.color.shade'] = shade if shade?

  LOI.Character.documents.update characterId, $set: set
    
LOI.Character.updateAvatarBody.method (characterId, address, value) ->
  check characterId, Match.DocumentId
  check address, String
  check value, Match.Any

  LOI.Authorize.characterAction characterId
  LOI.Authorize.avatarEditor()

  LOI.Character.documents.update characterId,
    $set:
      "avatar.body.#{address}": value

LOI.Character.updateAvatarOutfit.method (characterId, address, value) ->
  check characterId, Match.DocumentId
  check address, String
  check value, Match.Any

  # Note that we don't authorize avatar editor because all players can change their outfit.
  LOI.Authorize.characterAction characterId

  LOI.Character.documents.update characterId,
    $set:
      "avatar.outfit.#{address}": value

LOI.Character.updateBehavior.method (characterId, address, value) ->
  check characterId, Match.DocumentId
  check address, String
  check value, Match.Any

  LOI.Authorize.characterAction characterId
  LOI.Authorize.avatarEditor()

  LOI.Character.documents.update characterId,
    $set:
      "behavior.#{address}": value

LOI.Character.Template.updateData.method (templateId, address, value) ->
  check id, Match.DocumentId
  check address, String
  check value, Match.Any

  LOI.Authorize.avatarEditor()

  template = LOI.Character.Template.documents.findOne templateId
  
  # User must be the author of this template.
  user = Retronator.requireUser()
  throw new AE.UnauthorizedException "You must be the author of the template to change it." unless template.author._id is user._id

  LOI.Character.documents.update templateId,
    $set:
      "data.#{address}": value
