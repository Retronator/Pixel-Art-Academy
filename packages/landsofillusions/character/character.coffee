AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

class LOI.Character extends AM.Document
  # user: the owner of this character
  #   _id
  #   displayName
  #   publicName
  # ownerName: public name of the owner of this character
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
  @Meta
    name: 'LandsOfIllusions.Character'
    fields: =>
      user: @ReferenceField RA.User, ['displayName', 'publicName'] , true, 'characters', ['name']
      ownerName: @GeneratedField 'self', ['user'], (character) ->
        ownerName = character.user?.publicName or null
        [character._id, ownerName]
      avatar:
        fullName: @ReferenceField AB.Translation, ['translations'], false
        shortName: @ReferenceField AB.Translation, ['translations'], false

  displayName: ->
    @name or AB.translate(@constructor._babelSubscription, 'No Name').text
    
  colorObject: (relativeShade = 0) ->
    LOI.palette()?.color (@avatar?.color?.hue or 0), (@avatar?.color?.shade or 0) + 6 + relativeShade

if Meteor.isClient
  Meteor.startup ->
    LOI.Character._babelSubscription = AB.subscribeNamespace 'LandsOfIllusions.Character'
