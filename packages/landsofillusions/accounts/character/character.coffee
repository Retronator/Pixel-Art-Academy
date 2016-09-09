AB = Artificial.Babel
LOI = LandsOfIllusions

class LandsOfIllusionsAccountsCharacter extends Document
  # user: the owner of this character
  #   _id
  #   displayName
  # name: how the character is called
  # color: character's favorite color as used in the world, for example, in dialogs.
  #   hue: ramp index in the Atari 2600 palette
  #   shade: relative shade from -2 to +2
  @Meta
    name: 'LandsOfIllusionsAccountsCharacter'
    fields: =>
      user: @ReferenceField LOI.Accounts.User, ['displayName'] , true, 'characters', ['name']

  displayName: ->
    @name or AB.server.translate(@constructor._babelSubscription, 'No Name').text
    
  colorObject: (relativeShade = 0) ->
    LOI.palette()?.color (@color?.hue or 0), (@color?.shade or 0) + 6 + relativeShade

if Meteor.isClient
  Meteor.startup ->
    LOI.Accounts.Character._babelSubscription = AB.server.subscribeNamespace 'LOI.Accounts.Character'

LOI.Accounts.Character = LandsOfIllusionsAccountsCharacter
