AC = Artificial.Control
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Navigator extends LOI.Assets.Editor.Navigator
  @id: -> "LandsOfIllusions.Assets.SpriteEditor.Navigator"
  @register @id()

  template: -> @constructor.id()

  getThumbnailSpriteData: ->
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
    @_rotate -1

  onClickRotateRight: (event) ->
    @_rotate 1

  _rotate: (direction) ->
    loader = @interface.getLoaderForActiveFile()
    activeSide = loader.activeSide()
    sides = _.values LOI.Engine.RenderingSides.Keys

    activeSideIndex = _.indexOf sides, activeSide
    loader.activeSide sides[(activeSideIndex + direction + 8) % 8]
