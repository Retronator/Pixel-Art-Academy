AB = Artificial.Babel
LOI = LandsOfIllusions

class LOI.Avatar
  @translationKeys:
    fullName: 'fullName'
    shortName: 'shortName'
    description: 'description'

  # Initialize database parts of an NPC avatar.
  @initialize: (options) ->
    translationNamespace = "#{options.id}.Avatar"

    # On the server, create this avatar's translated names.
    if Meteor.isServer
      for key of LOI.Avatar.translationKeys
        AB.createTranslation translationNamespace, key, options[key] if options[key]

  constructor: (@options) ->
    translationNamespace = "#{@options.id}.Avatar"

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
