AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class Rot8 extends FM.Action
  enabled: -> @interface.getLoaderForActiveFile() instanceof LOI.Assets.SpriteEditor.Rot8Loader

  execute: ->
    loader = @interface.getLoaderForActiveFile()
    activeSide = loader.activeSide()
    sides = _.values LOI.Engine.RenderingSides.Keys

    activeSideIndex = _.indexOf sides, activeSide
    loader.activeSide sides[(activeSideIndex + @_direction + 8) % 8]

class LOI.Assets.SpriteEditor.Actions.Rot8Left extends Rot8
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.Rot8Left'
  @displayName: -> "Rot8 left"

  @initialize()

  constructor: ->
    super arguments...

    @_direction = -1

class LOI.Assets.SpriteEditor.Actions.Rot8Right extends Rot8
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.Rot8Right'
  @displayName: -> "Rot8 right"

  @initialize()

  constructor: ->
    super arguments...

    @_direction = 1
