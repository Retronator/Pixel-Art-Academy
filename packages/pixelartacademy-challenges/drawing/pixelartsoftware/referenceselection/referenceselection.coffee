AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Babel
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.PixelArtSoftware.ReferenceSelection extends PAA.PixelBoy.Apps.Drawing.Portfolio.Asset
  @id: -> "PixelArtAcademy.Challenges.Drawing.PixelArtSoftware.ReferenceSelection"

  @displayName: -> "Choose a sprite to copy"

  @description: -> """
    To make sure you are ready to complete pixel art drawing assignments, this challenge requires you to copy an
    existing game sprite.
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
    @customComponent = new @constructor.CustomComponent @
  
  urlParameter: -> 'select-reference'
  
  id: -> @constructor.id()

  displayName: -> AB.translate(@_translationSubscription, 'displayName').text
  displayNameTranslation: -> AB.translation @_translationSubscription, 'displayName'

  description: -> AB.translate(@_translationSubscription, 'description').text
  descriptionTranslation: -> AB.translation @_translationSubscription, 'description'

  width: -> 31
  height: -> 48
  
  ready: -> true
