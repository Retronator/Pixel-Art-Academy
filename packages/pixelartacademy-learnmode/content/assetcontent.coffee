AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Content.AssetContent extends LM.Content
  @projectClass = null # Override which project this asset belongs to.
  @assetClass = null # Override which project asset this sprite is.

  @type: -> 'AssetContent'
  
  @displayName: -> null # The name will match the asset's name.
  
  constructor: ->
    super arguments...
    
    # Stop previous translation and subscribe to the asset directly.
    assetTranslationNamespace = @constructor.assetClass.id()
    @_assetTranslationSubscription = AB.subscribeNamespace assetTranslationNamespace
    
    @progress = new LM.Content.Progress.ProjectAssetProgress
      content: @
      project: @constructor.projectClass
      asset: @constructor.assetClass
      
  destroy: ->
    super arguments...
    
    @_assetTranslationSubscription.stop()

  displayName: -> AB.translate(@_assetTranslationSubscription, 'displayName').text
  displayNameTranslation: -> AB.translation @_assetTranslationSubscription, 'displayName'
