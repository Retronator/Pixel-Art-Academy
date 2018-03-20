AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Items.Sync.Tab extends AM.Component
  @translationKeys:
    displayName: 'displayName'

  @url: -> throw new AE.NotImplementedException
  @displayName: -> throw new AE.NotImplementedException
    
  @initialize: ->
    translationNamespace = @componentName()

    # On the server, create this avatar's translated names.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty

        for translationKey of @translationKeys
          defaultText = _.propertyValue @, translationKey
          AB.createTranslation translationNamespace, translationKey, defaultText

  constructor: (@sync) ->
    super

    translationNamespace = @componentName()

    # Subscribe to translation keys in advance to avoid loading on display.
    Tracker.autorun (computation) =>
      AB.Translation.forNamespace.subscribe translationNamespace, null, AB.userLanguagePreference()

  url: -> @constructor.url()
    
  displayNameTranslation: ->
    translationNamespace = @componentName()

    # We directly return the translation document instead of going through the component since we subscribed on our own.
    AB.Translation.documents.findOne
      namespace: translationNamespace
      key: @constructor.translationKeys.displayName
