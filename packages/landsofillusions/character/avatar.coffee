AB = Artificial.Babel
LOI = LandsOfIllusions

# Character's implementation of the avatar that takes the data from the character document.
class LOI.Character.Avatar extends LOI.Avatar
  constructor: (@avatar) ->
    super

  fullName: ->
    return @_loading() unless @avatar

    @avatar.fullName?.translate().text or @_noName()

  shortName: ->
    return @_loading() unless @avatar

    @avatar.shortName?.translate().text or @fullName()

  _loading: ->
    return if Meteor.isServer

    AB.translate(@constructor._babelSubscription, 'Loading …').text

  _noName: ->
    return if Meteor.isServer

    AB.translate(@constructor._babelSubscription, 'No Name').text

  color: ->
    @avatar?.color or super

if Meteor.isClient
  Meteor.startup ->
    LOI.Character.Avatar._babelSubscription = AB.subscribeNamespace 'LandsOfIllusions.Character.Avatar'
