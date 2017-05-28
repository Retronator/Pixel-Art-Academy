AM = Artificial.Mummification
AB = Artificial.Babel
LOI = LandsOfIllusions

# Character's implementation of the avatar that takes the data from the character document.
class LOI.Character.Avatar extends LOI.Avatar
  constructor: (@character) ->
    super

    # Create the body and outfit hierarchies.
    @body = AM.Hierarchy.create
      load: => @_avatar()?.body
      save: (address, value) =>
        LOI.Character.updateAvatarBody @character.id, address, value

    @outfit = AM.Hierarchy.create
      load: => @_avatar().outfit
      save: (address, value) =>
        LOI.Character.updateAvatarOutfit @character.id, address, value

  _avatar: ->
    @character.document()?.avatar

  fullName: ->
    return @_loading() unless avatar = @_avatar()

    avatar.fullName?.translate().text or @_noName()

  shortName: ->
    return @_loading() unless avatar = @_avatar()

    avatar.shortName?.translate().text or @fullName()

  _loading: ->
    return if Meteor.isServer

    AB.translate(@constructor._babelSubscription, 'Loading …').text

  _noName: ->
    return if Meteor.isServer

    AB.translate(@constructor._babelSubscription, 'No Name').text

  color: ->
    @_avatar()?.color or super

if Meteor.isClient
  Meteor.startup ->
    LOI.Character.Avatar._babelSubscription = AB.subscribeNamespace 'LandsOfIllusions.Character.Avatar'
