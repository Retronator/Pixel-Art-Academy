AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Actions.ZoomIn extends FM.Action
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.ZoomIn'
  @displayName: -> "Zoom in"

  @initialize()

  enabled: -> @interface.parent.spriteData()

  execute: ->
    # TODO: Send zoom in command to the camera of the focused file.

class LOI.Assets.SpriteEditor.Actions.ZoomOut extends FM.Action
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.ZoomOut'
  @displayName: -> "Zoom out"

  @initialize()

  enabled: -> @interface.parent.spriteData()

  execute: ->
    # TODO: Send zoom out command to the camera of the focused file.
