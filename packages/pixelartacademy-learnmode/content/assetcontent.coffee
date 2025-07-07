AE = Artificial.Everywhere
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Content.AssetContent extends LM.Content
  @type: -> 'AssetContent'
  
  @assetClass = null # Override which project asset this sprite is.
  
  @displayName: -> @assetClass.displayName()
  
  constructor: ->
    super arguments...
    
    @progress = new LM.Content.Progress.ProjectAssetProgress
      content: @
      project: PAA.Pico8.Cartridges.Snake.Project
      asset: @constructor.assetClass
