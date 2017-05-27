AB = Artificial.Babel
LOI = LandsOfIllusions

# Thing's implementation of the avatar that handles translating things.
class LOI.Adventure.Thing.Avatar extends LOI.Avatar
  @translationKeys:
    fullName: 'fullName'
    shortName: 'shortName'
    description: 'description'

  # Initialize database parts of an avatar.
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
    super
    
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
    # Return the desired color or use the default.
    color = _.propertyValue @options, 'color'

    color or super

  dialogTextTransform: -> _.propertyValue @options, 'dialogTextTransform'
  dialogDeliveryType: -> _.propertyValue @options, 'dialogDeliveryType'

  _translateIfAvailable: (key) ->
    translated = AB.translate @_translationSubscription, key
    if translated.language then translated.text else null
