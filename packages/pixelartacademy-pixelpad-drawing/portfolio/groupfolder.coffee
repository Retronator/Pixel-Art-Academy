AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.PixelPad.Apps.Drawing.Portfolio.GroupFolder
  @id: -> throw new AE.NotImplementedException "You must specify the folder ID."
  
  @displayName: -> throw new AE.NotImplementedException "You must specify the folder display name."
  
  @initialize: ->
    # On the server, create this folder's translated name.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty
        
        translationNamespace = @id()
        AB.createTranslation translationNamespace, 'displayName', @displayName()
        
  constructor: ->
    # Subscribe to this folder's translations.
    translationNamespace = @id()
    @_translationSubscription = AB.subscribeNamespace translationNamespace
    
    @things = []
  
  destroy: ->
    @_translationSubscription.stop()
  
  id: -> @constructor.id()
  
  displayName: -> AB.translate(@_translationSubscription, 'displayName').text
  displayNameTranslation: -> AB.translation @_translationSubscription, 'displayName'

  styleClasses: -> '' # Override to provide a string with class names for styling the asset.
