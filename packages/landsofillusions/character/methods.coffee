AB = Artificial.Babel
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

LOI.Character.removeUser.method (characterId) ->
  check characterId, Match.DocumentId

  LOI.Authorize.player()
  LOI.Authorize.characterAction characterId

  LOI.Character.documents.update characterId,
    $set:
      user: null
  
LOI.Character.updateName.method (characterId, nameField, language, name) ->
  check characterId, Match.DocumentId
  check nameField, Match.OneOf 'fullName', 'shortName'
  check name, String

  LOI.Authorize.player()
  LOI.Authorize.characterAction characterId

  # Check if this name is present.
  character = LOI.Character.documents.findOne characterId

  # If name is not present, but we're also trying to set an empty name, there's nothing to do.
  return unless character.avatar?[nameField] or name

  # Create the translation if it's not.
  if character.avatar?[nameField]
    translationId = character.avatar[nameField]._id

  else
    translationId = AB.Translation.documents.insert {}

    LOI.Character.documents.update characterId,
      $set:
        "avatar.#{nameField}._id": translationId

  # If we have a name, update the translation, otherwise delete it (default will be used).
  if name
    AB.Translation._update translationId, language, name

  else
    AB.Translation._removeLanguage translationId, language

    # See if we have any translations left, otherwise delete the whole translation document.
    translation = AB.Translation.documents.findOne translationId

    # On the client, it's OK if the translation is not there.
    return if Meteor.isClient and not translation

    # We know we don't have translations if the best text becomes null.
    unless translation.translations.best.text
      LOI.Character.documents.update characterId,
        $unset:
          "avatar.#{nameField}": true

      AB.Translation._remove translationId

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

updateCharacterPart = (field, characterId, address, value) ->
  field += ".#{address}" if address

  if value?
    update =
      $set:
        "#{field}": value
  else
    update =
      $unset:
        "#{field}": true

  LOI.Character.documents.update characterId, update

LOI.Character.updateAvatarBody.method (characterId, address, value) ->
  check characterId, Match.DocumentId
  check address, String
  check value, Match.Any

  LOI.Authorize.characterAction characterId
  LOI.Authorize.avatarEditor()

  updateCharacterPart 'avatar.body', characterId, address, value

LOI.Character.updateAvatarOutfit.method (characterId, address, value) ->
  check characterId, Match.DocumentId
  check address, String
  check value, Match.Any

  # Note that we don't authorize avatar editor because all players can change their outfit.
  LOI.Authorize.characterAction characterId

  updateCharacterPart 'avatar.outfit', characterId, address, value

LOI.Character.updateBehavior.method (characterId, address, value) ->
  check characterId, Match.DocumentId
  check address, String
  check value, Match.Any

  LOI.Authorize.characterAction characterId
  LOI.Authorize.avatarEditor()

  updateCharacterPart 'behavior', characterId, address, value

LOI.Character.approveDesign.method (characterId) ->
  check characterId, Match.DocumentId

  LOI.Authorize.player()
  LOI.Authorize.characterAction characterId

  LOI.Character.documents.update characterId,
    $set:
      designApproved: true

LOI.Character.approveBehavior.method (characterId) ->
  check characterId, Match.DocumentId

  LOI.Authorize.player()
  LOI.Authorize.characterAction characterId

  LOI.Character.documents.update characterId,
    $set:
      behaviorApproved: true

LOI.Character.activate.method (characterId) ->
  check characterId, Match.DocumentId

  LOI.Authorize.player()
  LOI.Authorize.characterAction characterId

  LOI.Character.documents.update characterId,
    $set:
      activated: true

  # TODO: Create character state etc.
