AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Babel
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.ReferenceSelection extends PAA.PixelPad.Apps.Drawing.Portfolio.Asset
  @displayName: -> throw new AE.NotImplementedException "Provide a name for the reference selection asset."
  @description: -> throw new AE.NotImplementedException "Provide the description text explaining the context for the reference."
  
  @portfolioComponentClass: -> throw new AE.NotImplementedException "Specify the component that shows up in the portfolio."
  @customComponentClass: -> throw new AE.NotImplementedException "Specify the component that enables the selection of the reference."
  
  @initialize: ->
    # On the server, create this asset's translated names.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty
      
        translationNamespace = @id()
        AB.createTranslation translationNamespace, property, @[property]() for property in ['displayName', 'description']
  
  constructor: ->
    super arguments...
    
    # Subscribe to this asset's translations.
    translationNamespace = @id()
    @_translationSubscription = AB.subscribeNamespace translationNamespace
    
    portfolioComponentClass = @constructor.portfolioComponentClass()
    customComponentClass = @constructor.customComponentClass()
    
    @portfolioComponent = new portfolioComponentClass @
    @customComponent = new customComponentClass @
  
  id: -> @constructor.id()

  displayName: -> AB.translate(@_translationSubscription, 'displayName').text
  displayNameTranslation: -> AB.translation @_translationSubscription, 'displayName'

  description: -> AB.translate(@_translationSubscription, 'description').text
  descriptionTranslation: -> AB.translation @_translationSubscription, 'description'

  ready: -> true
