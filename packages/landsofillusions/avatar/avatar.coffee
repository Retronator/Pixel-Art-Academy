AB = Artificial.Babel
LOI = LandsOfIllusions

class LOI.Avatar
  @translationKeys:
    fullName: 'fullName'
    shortName: 'shortName'
    description: 'description'
    
  @NameAutoCorrectStyle:
    Word: 'Word'
    Name: 'Name'

  @DialogTextTransform:
    Auto: 'Auto'
    Uppercase: 'Uppercase'
    Lowercase: 'Lowercase'

  @DialogDeliveryType:
    Saying: 'Saying'
    Displaying: 'Displaying'

  # Initialize database parts of an NPC avatar.
  @initialize: (options) ->
    id = _.propertyValue options, 'id'
    translationNamespace = "#{id}.Avatar"

    # On the server, create this avatar's translated names.
    if Meteor.isServer
      Document.startup =>
        for translationKey of @translationKeys
          defaultText = _.propertyValue options, translationKey
          AB.createTranslation translationNamespace, translationKey, defaultText if defaultText

  constructor: (@options) ->
    id = _.propertyValue @options, 'id'
    translationNamespace = "#{id}.Avatar"

    # Subscribe to this avatar's translations.
    @_translationSubscription = AB.subscribeNamespace translationNamespace

  destroy: ->
    @_translationSubscription.stop()

  ready: ->
    @_translationSubscription.ready()

  fullName: -> @_translateIfAvailable @constructor.translationKeys.fullName
  shortName: -> @_translateIfAvailable @constructor.translationKeys.shortName
  description: -> @_translateIfAvailable @constructor.translationKeys.description
    
  nameAutoCorrectStyle: -> _.propertyValue @options, 'nameAutoCorrectStyle'
    
  color: ->
    # Return the desired color or use default white.
    color = _.propertyValue @options, 'color'

    color or
      hue: LOI.Assets.Palette.Atari2600.hues.grey
      shade: LOI.Assets.Palette.Atari2600.characterShades.normal

  colorObject: ->
    @constructor.colorObject @color()

  @colorObject: (color) ->
    LOI.palette()?.color color.hue, color.shade + 6

  dialogTextTransform: -> _.propertyValue @options, 'dialogTextTransform'
  dialogDeliveryType: -> _.propertyValue @options, 'dialogDeliveryType'

  _translateIfAvailable: (key) ->
    translated = AB.translate @_translationSubscription, key
    if translated.language then translated.text else null
