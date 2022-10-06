AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Actions.FlipHorizontal extends LOI.Assets.Editor.Actions.AssetAction
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.FlipHorizontal'
  @displayName: -> "Flip horizontal"
    
  @initialize()

  execute: ->
    asset = @asset()
    LOI.Assets.Sprite.flipHorizontal asset._id, 0

    # Note: landmark operations are currently not added to history while the pixel changes are.
    if asset.landmarks
      for landmark, index in asset.landmarks when landmark.x
        LOI.Assets.VisualAsset.updateLandmark asset.constructor.className, asset._id, index,
          x: -landmark.x
