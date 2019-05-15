AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Actions.Export extends LOI.Assets.Editor.Actions.Export
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.Export'
  @displayName: -> "Export"

  @initialize()

  getPreviewImage: (sprite) ->
    engineSprite = new LOI.Assets.Engine.Sprite
      spriteData: -> sprite

    engineSprite.getCanvas()
