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

  mipmaps: ->
    loader = @interface.getLoaderForActiveFile()
    return unless loader instanceof LOI.Assets.SpriteEditor.MipLoader

    loader.mipmaps()

  activeMipmapClass: ->
    mipmap = @currentData()
    loader = @interface.getLoaderForActiveFile()
    activeMipmap = loader.activeMipmap()

    'active' if mipmap._id is activeMipmap._id

  # Events

  events: ->
    super(arguments...).concat
      'click .rotate-left-button': @onClickRotateLeft
      'click .rotate-right-button': @onClickRotateRight
      'click .mipmap-button': @onClickMipmapButton

  onClickRotateLeft: (event) ->
    @interface.getOperator(LOI.Assets.SpriteEditor.Actions.Rot8Left).execute()

  onClickRotateRight: (event) ->
    @interface.getOperator(LOI.Assets.SpriteEditor.Actions.Rot8Right).execute()

  onClickMipmapButton: (event) ->
    mipmap = @currentData()
    loader = @interface.getLoaderForActiveFile()

    loader.activateMipmap mipmap
