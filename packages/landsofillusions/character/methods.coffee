AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mummification
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

  # Remove the active user link and archive it for possible use.
  LOI.Character.documents.update characterId,
    $set:
      user: null
      archivedUser:
        _id: Meteor.userId()
  
LOI.Character.updateName.method (characterId, language, name) ->
  check characterId, Match.DocumentId
  check name, String

  LOI.Authorize.player()
  LOI.Authorize.characterAction characterId

  # Check if this name is present.
  character = LOI.Character.documents.findOne characterId

  # If name is not present, but we're also trying to set an empty name, there's nothing to do.
  return unless character.avatar?.fullName or name

  # Create the translation if it's not.
  if character.avatar?.fullName
    translationId = character.avatar.fullName._id

  else
    translationId = AB.Translation.documents.insert {}

    LOI.Character.documents.update characterId,
      $set:
        "avatar.fullName._id": translationId

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
          "avatar.fullName": true

      AB.Translation._remove translationId

LOI.Character.updatePronouns.method (characterId, pronouns) ->
  check characterId, Match.DocumentId
  check pronouns, Match.Enumeration String, LOI.Avatar.Pronouns

  LOI.Authorize.player()
  LOI.Authorize.characterAction characterId

  LOI.Character.documents.update characterId,
    $set:
      'avatar.pronouns': pronouns

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

updateCharacterPart = (field, characterId, address, value, additionalUpdate) ->
  field += ".#{address}" if address

  if value?
    # Denormalize data into a template field when we have a specific version (otherwise we want live updating).
    LOI.Character.Part.Template.denormalizeTemplateField value.template if value.template?.version?

    update =
      $set:
        "#{field}": value
  else
    update =
      $unset:
        "#{field}": true

  if additionalUpdate
    _.merge update, additionalUpdate

  LOI.Character.documents.update characterId, update

updateAvatarPart =  (field, characterId, address, value) ->
  updateCharacterPart field, characterId, address, value,
    $set:
      'avatar.textures.needUpdate': true

LOI.Character.updateAvatarBody.method (characterId, address, value) ->
  check characterId, Match.DocumentId
  check address, String
  check value, Match.Any

  LOI.Authorize.characterAction characterId
  LOI.Authorize.avatarEditor()

  updateAvatarPart 'avatar.body', characterId, address, value

LOI.Character.updateAvatarOutfit.method (characterId, address, value) ->
  check characterId, Match.DocumentId
  check address, String
  check value, Match.Any

  # Note that we don't authorize avatar editor because all players can change their outfit.
  LOI.Authorize.characterAction characterId

  updateAvatarPart 'avatar.outfit', characterId, address, value

LOI.Character.updateBehavior.method (characterId, address, value) ->
  check characterId, Match.DocumentId
  check address, String
  check value, Match.Any

  LOI.Authorize.characterAction characterId
  LOI.Authorize.avatarEditor()

  updateCharacterPart 'behavior', characterId, address, value

LOI.Character.updateProfile.method (characterId, address, value) ->
  check characterId, Match.DocumentId
  check address, String
  check value, Match.Any

  # Treat empty strings are deletion of value.
  value = null if value is ''

  if value
    switch address
      when 'age' then check value, Match.IntegerRange 13, 150
      when 'country' then check value, Match.Where (value) -> value in AB.Region.documents.find().map (region) -> region.code

  LOI.Authorize.characterAction characterId

  updateCharacterPart 'profile', characterId, address, value
  
LOI.Character.updateContactEmail.method (characterId, emailAddress) ->
  check characterId, Match.DocumentId
  check emailAddress, String

  LOI.Authorize.player()
  LOI.Authorize.characterAction characterId

  user = Retronator.user()
  emailIndex = _.findIndex user.registered_emails, (email) -> email.address is emailAddress and email.verified

  throw new AE.ArgumentException "You must provide a verified email address." if emailIndex is -1

  LOI.Character.documents.update characterId,
    $set:
      'contactEmail': emailAddress

LOI.Character.approveDesign.method (characterId) ->
  check characterId, Match.DocumentId

  LOI.Authorize.player()
  LOI.Authorize.characterAction characterId

  LOI.Character.documents.update characterId,
    $set:
      designApproved: true
      
  # Also render avatar textures for the first time.
  LOI.Character.renderAvatarTextures characterId

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

  # Create new game state for the character.
  LOI.GameState.insertForCharacter characterId
