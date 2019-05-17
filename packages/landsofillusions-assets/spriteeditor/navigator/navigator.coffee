AC = Artificial.Control
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Navigator extends LOI.Assets.Editor.Navigator
  @id: -> "LandsOfIllusions.Assets.SpriteEditor.Navigator"
  @register @id()

  getThumbnailSpriteData: ->
    @interface.getEditorForActiveFile()?.spriteData()
