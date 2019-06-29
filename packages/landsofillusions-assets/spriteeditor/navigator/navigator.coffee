AC = Artificial.Control
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Navigator extends LOI.Assets.Editor.Navigator
  @id: -> "LandsOfIllusions.Assets.SpriteEditor.Navigator"
  @register @id()

  template: -> @constructor.id()

  sprite: ->
    @interface.getEditorForActiveFile()?.spriteData()

  rot8side: ->
    loader = @interface.getLoaderForActiveFile()
    return unless loader instanceof LOI.Assets.SpriteEditor.Rot8Loader

    _.kebabCase loader.activeSide()

  # Events

  events: ->
    super(arguments...).concat
      'click .rotate-left-button': @onClickRotateLeft
      'click .rotate-right-button': @onClickRotateRight

  onClickRotateLeft: (event) ->
    @interface.getOperator(LOI.Assets.SpriteEditor.Actions.Rot8Left).execute()

  onClickRotateRight: (event) ->
    @interface.getOperator(LOI.Assets.SpriteEditor.Actions.Rot8Right).execute()
