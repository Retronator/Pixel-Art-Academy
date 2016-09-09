LOI = LandsOfIllusions

Meteor.methods
  'LandsOfIllusions.Accounts.Character.insert': (userId, characterId) ->
    check userId, Match.DocumentId
    check characterId, Match.Optional Match.DocumentId

    currentUserId = Meteor.userId()

    # An admin can always add a character.
    unless Roles.userIsInRole currentUserId, 'admin'
      # Only the user itself can add a character.
      throw new Meteor.Error 'unauthorized', "Unauthorized." unless currentUserId is userId

      # User must have the create-character role
      throw new Meteor.Error 'unauthorized', "Unauthorized." unless Roles.userIsInRole currentUserId, 'create-character'

    character =
      user:
        _id: userId
      name: ""
      color:
        hue: 0
        shade: 0

    character._id = characterId if characterId

    LOI.Accounts.Character.documents.insert character

  'LandsOfIllusions.Accounts.Character.rename': (characterId, name) ->
    check characterId, Match.DocumentId
    check name, String

    LOI.Authorize.characterAction characterId

    LOI.Accounts.Character.documents.update characterId,
      $set:
        name: name

  'LandsOfIllusions.Accounts.Character.changeColor': (characterId, hue, shade) ->
    check characterId, Match.DocumentId
    check hue, Match.OptionalOrNull Match.Integer
    check shade, Match.OptionalOrNull Match.Integer

    LOI.Authorize.characterAction characterId

    set = {}
    set['color.hue'] = hue if hue?
    set['color.shade'] = shade if shade?

    LOI.Accounts.Character.documents.update characterId, $set: set
