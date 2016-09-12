AE = Artificial.Everywhere
LOI = LandsOfIllusions

Meteor.methods
  'LandsOfIllusions.Character.insert': (userId, characterId) ->
    check userId, Match.DocumentId
    check characterId, Match.Optional Match.DocumentId

    user = Retronator.user()
    throw new AE.UnauthorizedException "You must be logged in to create a character." unless user

    # An admin can always add a character.
    unless user.hasItem 'Retronator.Admin'
      # Only the user itself can add a character.
      throw new AE.UnauthorizedException "You can only create characters that belong to you." unless user._id is userId

      # User must have the create-character role
      throw new AE.UnauthorizedException "You must be able to create characters." unless user.hasItem 'LandsOfIllusions.Character.Creation'

    character =
      user:
        _id: userId
      name: ""
      color:
        hue: 0
        shade: 0

    character._id = characterId if characterId

    LOI.Character.documents.insert character

  'LandsOfIllusions.Character.rename': (characterId, name) ->
    check characterId, Match.DocumentId
    check name, String

    LOI.Authorize.characterAction characterId

    LOI.Character.documents.update characterId,
      $set:
        name: name

  'LandsOfIllusions.Character.changeColor': (characterId, hue, shade) ->
    check characterId, Match.DocumentId
    check hue, Match.OptionalOrNull Match.Integer
    check shade, Match.OptionalOrNull Match.Integer

    LOI.Authorize.characterAction characterId

    set = {}
    set['color.hue'] = hue if hue?
    set['color.shade'] = shade if shade?

    LOI.Character.documents.update characterId, $set: set
