AM = Artificial.Mummification
AB = Artificial.Babel
LOI = LandsOfIllusions

# Character's implementation of the avatar that takes the data from the character document.
class LOI.Character.Avatar extends LOI.HumanAvatar
  constructor: (@character) ->
    # Create the body and outfit data hierarchies first.
    body = AM.Hierarchy.create
      load: => @_avatar()?.body
      save: (address, value) =>
        LOI.Character.updateAvatarBody @character.id, address, value

    outfit = AM.Hierarchy.create
      load: => @_avatar()?.outfit
      save: (address, value) =>
        LOI.Character.updateAvatarOutfit @character.id, address, value

    @_dataNode = AM.Hierarchy.create
      load: => {body, outfit}

    # Now we can call HumanAvatar's constructor which will turn this data into an actual part hierarchy.
    super

  _avatar: ->
    @character.document()?.avatar

  dataNode: -> @_dataNode

  fullName: ->
    return @_loading() unless character = @character.document()

    character.avatar?.fullName?.translate().text or @_noName()

  shortName: ->
    return @_loading() unless character = @character.document()

    character.avatar?.shortName?.translate().text or @fullName()

  _loading: ->
    return if Meteor.isServer

    AB.translate(@constructor._babelSubscription, 'Loading …').text

  _noName: ->
    return if Meteor.isServer

    @constructor.noName()

  color: ->
    @character.document()?.avatar?.color or super

  @noNameTranslation: ->
    AB.translation @_babelSubscription, 'No Name'

  @noName: ->
    @noNameTranslation().translate().text

if Meteor.isClient
  Meteor.startup ->
    # Subscribe to the avatar namespace in all languages, so that we can show all translations of "No Name" in the
    # dialogs. We do this because of a limitation in Meteor, where we can't later on request to get all translations
    # (top field), if we subscribed just to some translations (subfields) earlier.
    LOI.Character.Avatar._babelSubscription = AB.subscribeNamespace 'LandsOfIllusions.Character.Avatar', null
