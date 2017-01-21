AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts

class LOI.Components.Account.Page extends AM.Component
  @translationKeys:
    displayName: 'displayName'

  @url: -> throw new AE.NotImplementedException
  @displayName: -> throw new AE.NotImplementedException
    
  @initialize: ->
    translationNamespace = @componentName()

    # On the server, create this avatar's translated names.
    if Meteor.isServer
      for translationKey of @translationKeys
        defaultText = _.propertyValue @, translationKey
        AB.createTranslation translationNamespace, translationKey, defaultText

  url: -> @constructor.url()
    
  displayNameTranslation: ->
    # We need component translations, but they won't be subscribed to until the page component has finished creating.
    return unless @isCreated()

    @translation @constructor.translationKeys.displayName
