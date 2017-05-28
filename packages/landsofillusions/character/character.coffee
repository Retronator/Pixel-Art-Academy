AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

class LOI.Character extends AM.Document
  @id: -> 'LandsOfIllusions.Character'
  # user: the owner of this character
  #   _id
  #   displayName
  #   publicName
  # ownerName: public name of the owner of this character
  # displayName: auto-generated best translation of the full name of this character for debugging (do not use in the game!).
  # avatar: information for the representation of the character
  #   fullName: how the character is fully named
  #     _id
  #     translations
  #   shortName: how the character can be quickly referred to
  #     _id
  #     translations
  #   color: character's favorite color as used in the world, for example, in dialogs
  #     hue: ramp index in the Atari 2600 palette
  #     shade: relative shade from -2 to +2
  #   body: avatar data for character's body representation
  #   outfit: avatar data for character's current clothes/accessories
  # behavior: avatar data for character's behavior design
  @Meta
    name: @id()
    fields: =>
      user: @ReferenceField RA.User, ['displayName', 'publicName'] , true, 'characters', ['displayName']
      ownerName: @GeneratedField 'self', ['user'], (character) ->
        ownerName = character.user?.publicName or null
        [character._id, ownerName]
        displayName: @GeneratedField 'self', ['avatar'], (character) ->
          displayName = character.avatar.fullName?.translations?.best?.text or null
          [character._id, displayName]
      avatar:
        fullName: @ReferenceField AB.Translation, ['translations'], false
        shortName: @ReferenceField AB.Translation, ['translations'], false
  
  # Methods

  @insert: @method 'insert'
  @updateColor: @method 'setColor'
  @updateAvatarBody: @method 'updateAvatarBody'
  @updateAvatarOutfit: @method 'updateAvatarOutfit'
  @updateBehavior: @method 'updateBehavior'

  # Subscriptions

  @forId: @subscription 'forId'
  @forCurrentUser: @subscription 'forCurrentUser'
