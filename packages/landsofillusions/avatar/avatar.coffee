AB = Artificial.Babel
LOI = LandsOfIllusions

class LOI.Avatar
  @translationKeys:
    fullName: 'fullName'
    shortName: 'shortName'
    description: 'description'

  # Initialize database parts of an NPC avatar.
  @initialize: (options) ->
    id = _.propertyValue options.id
    translationNamespace = "#{id}.Avatar"

    # On the server, create this avatar's translated names.
    if Meteor.isServer
      for translationKey of @translationKeys
        defaultText = _.propertyValue options[translationKey]
        AB.createTranslation translationNamespace, translationKey, defaultText if defaultText

  constructor: (@options) ->
    id = _.propertyValue @options.id
    translationNamespace = "#{id}.Avatar"

    # Subscribe to this avatar's translations.
    @_translationSubscribtion = AB.subscribeNamespace translationNamespace

  destroy: ->
    @_translationSubscribtion.stop()

  ready: ->
    @_translationSubscribtion.ready()

  fullName: -> @_translateIfAvailable @constructor.translationKeys.fullName
  shortName: -> @_translateIfAvailable @constructor.translationKeys.shortName
  description: -> @_translateIfAvailable @constructor.translationKeys.description
    
  color: ->
    # Return the desired color or use default white.
    @options.color or
      hue: LOI.Assets.Palette.Atari2600.hues.grey
      shade: LOI.Assets.Palette.Atari2600.characterShades.normal

  _translateIfAvailable: (key) ->
    translated = AB.translate @_translationSubscribtion, key
    if translated.language then translated.text else null
