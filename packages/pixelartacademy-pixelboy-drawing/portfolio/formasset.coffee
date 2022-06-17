AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PixelArtAcademy.PixelBoy.Apps.Drawing.Portfolio.FormAsset
  # Id string for this asset used to identify the asset in code.
  @id: -> throw new AE.NotImplementedException "You must specify asset's id."

  # String to represent the asset in the UI. Note that we can't use
  # 'name' since it's an existing property holding the class name.
  @displayName: -> throw new AE.NotImplementedException "You must specify the asset name."

  # String with more information about what this asset represents.
  @description: -> throw new AE.NotImplementedException "You must specify the asset's description."

  @initialize: ->
    # On the server, create this assets's translated names.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty

        translationNamespace = @id()
        AB.createTranslation translationNamespace, property, @[property]() for property in ['displayName', 'description']

  constructor: ->
    # Subscribe to this asset's translations.
    translationNamespace = @id()
    @_translationSubscription = AB.subscribeNamespace translationNamespace

  destroy: ->
    @_translationSubscription.stop()
    @data.stop()

  id: -> @constructor.id()

  displayName: -> AB.translate(@_translationSubscription, 'displayName').text
  displayNameTranslation: -> AB.translation @_translationSubscription, 'displayName'

  description: -> AB.translate(@_translationSubscription, 'description').text
  descriptionTranslation: -> AB.translation @_translationSubscription, 'description'

  styleClasses: -> '' # Override to provide a string with class names for styling the asset.

  editorStyleClasses: -> '' # Override to provide a string with class names for styling the surrounding editor.
  
  width: -> 48
  height: -> 64
