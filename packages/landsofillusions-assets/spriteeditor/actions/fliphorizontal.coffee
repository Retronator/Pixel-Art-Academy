AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Actions.FlipHorizontal extends LOI.Assets.Editor.Actions.AssetAction
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.FlipHorizontal'
  @displayName: -> "Flip horizontal"
    
  @initialize()

  execute: ->
    sprite = @asset()
    LOI.Assets.Sprite.flipHorizontal sprite._id, 0

    # Note: landmark operations are currently not added to history while the pixel changes are.
    if sprite.landmarks
      for landmark, index in sprite.landmarks when landmark.x
        LOI.Assets.VisualAsset.updateLandmark sprite.constructor.className, sprite._id, index,
          x: -landmark.x
