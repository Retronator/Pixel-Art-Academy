AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
LOI = LandsOfIllusions

DesignDocument = PAA.Pico8.Cartridges.Invasion.DesignDocument

class DesignDocument.Asset extends PAA.PixelPad.Apps.Drawing.Portfolio.Asset
  @id: -> 'PixelArtAcademy.Pico8.Cartridges.Invasion.DesignDocument.Asset'
  @type: -> @Types.None
  
  @displayName: -> "Design Document"

  @description: -> "Specifies the design of the Invasion game."

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

    @portfolioComponent = new DesignDocument.PortfolioComponent @

  destroy: ->
    @_translationSubscription.stop()

  id: -> @constructor.id()

  displayName: -> AB.translate(@_translationSubscription, 'displayName').text
  displayNameTranslation: -> AB.translation @_translationSubscription, 'displayName'

  description: -> AB.translate(@_translationSubscription, 'description').text
  descriptionTranslation: -> AB.translation @_translationSubscription, 'description'

  width: -> 63
  height: -> 85
  
  ready: -> true
  
  urlParameter: -> 'designdocument'
  
  onClick: ->
    pixelPad = LOI.adventure.getCurrentThing PAA.PixelPad
    pixelPad.os.go PAA.PixelPad.Apps.Pixeltosh.url()
    
    Tracker.autorun (computation) ->
      return unless pixeltoshOS = PAA.PixelPad.Apps.Pixeltosh.getOS()
      computation.stop()
      
      writer = pixeltoshOS.getProgram PAA.Pixeltosh.Programs.Writer
      file = pixeltoshOS.fileSystem.getFileForPath 'Invasion/Invasion Design Document'
      pixeltoshOS.loadProgram writer, file
