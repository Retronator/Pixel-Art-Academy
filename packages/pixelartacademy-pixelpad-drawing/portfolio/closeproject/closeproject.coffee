AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Babel
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.Portfolio.CloseProject extends PAA.PixelPad.Apps.Drawing.Portfolio.Asset
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.CloseProject'
  
  @type: -> @Types.None
  
  @displayName: -> "Close project"
  
  @description: -> """
    Store project assets in this folder to work on other project variants.
  """
  
  @initialize: ->
    # On the server, create this assets's translated names.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty
        
        translationNamespace = @id()
        AB.createTranslation translationNamespace, property, @[property]() for property in ['displayName', 'description']
  
  @initialize()
  
  constructor: ->
    super arguments...
    
    # Subscribe to this asset's translations.
    translationNamespace = @id()
    @_translationSubscription = AB.subscribeNamespace translationNamespace
    
    @portfolioComponent = new @constructor.PortfolioComponent @

  destroy: ->
    @_translationSubscription.stop()
    
  urlParameter: -> 'close-project'
  
  id: -> @constructor.id()
  
  displayName: -> AB.translate(@_translationSubscription, 'displayName').text
  displayNameTranslation: -> AB.translation @_translationSubscription, 'displayName'
  
  description: -> AB.translate(@_translationSubscription, 'description').text
  descriptionTranslation: -> AB.translation @_translationSubscription, 'description'
  
  width: -> 75
  height: -> 100
  
  ready: -> true
