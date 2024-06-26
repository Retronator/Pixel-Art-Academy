AB = Artificial.Babel
LOI = LandsOfIllusions

# Thing's implementation of the avatar that handles translating things.
class LOI.Adventure.Thing.Avatar extends LOI.Avatar
  @translationKeys:
    fullName: 'fullName'
    shortName: 'shortName'
    descriptiveName: 'descriptiveName'
    description: 'description'
    storeName: 'storeName'
    storeDescription: 'storeDescription'

  # Initialize database parts of an avatar.
  @initialize: (options) ->
    id = _.propertyValue options, 'id'
    translationNamespace = "#{id}.Avatar"

    # On the server, create this avatar's translated names.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty

        for translationKey of @translationKeys
          defaultText = _.propertyValue options, translationKey
          AB.createTranslation translationNamespace, translationKey, defaultText if defaultText

  constructor: (@thingClass) ->
    super arguments...
    
    id = _.propertyValue @thingClass, 'id'
    translationNamespace = "#{id}.Avatar"

    # Subscribe to this avatar's translations.
    @_translationSubscription = AB.subscribeNamespace translationNamespace

  destroy: ->
    super arguments...

    @_translationSubscription.stop()

  ready: ->
    @_translationSubscription.ready()

  fullName: -> @_translateIfAvailable @constructor.translationKeys.fullName
  shortName: -> @_translateIfAvailable @constructor.translationKeys.shortName
  descriptiveName: -> @_translateIfAvailable @constructor.translationKeys.descriptiveName
  description: -> @_translateIfAvailable @constructor.translationKeys.description

  pronouns: -> _.propertyValue @thingClass, 'pronouns'
  nameAutoCorrectStyle: -> _.propertyValue @thingClass, 'nameAutoCorrectStyle'
  nameNounType: -> _.propertyValue @thingClass, 'nameNounType'

  color: ->
    # Return the desired color or use the default.
    color = _.propertyValue @thingClass, 'color'

    color or super arguments...

  dialogTextTransform: -> _.propertyValue @thingClass, 'dialogTextTransform'
  dialogueDeliveryType: -> _.propertyValue @thingClass, 'dialogueDeliveryType'

  _translateIfAvailable: (key) ->
    translated = AB.translate @_translationSubscription, key
    if translated.language then translated.text else null

  getTranslation: (key) ->
    AB.existingTranslation @_translationSubscription, key
    
  getRenderObject: ->
    return unless thingIllustration = @thingClass.illustration?()

    LOI.adventure.world.sceneManager()?.getMeshObject thingIllustration.mesh, thingIllustration.object
