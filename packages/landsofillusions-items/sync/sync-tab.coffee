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

  url: -> @constructor.url()
    
  displayNameTranslation: ->
    @translation @constructor.translationKeys.displayName
