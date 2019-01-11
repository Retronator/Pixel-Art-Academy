AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Layers extends FM.View
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Layers'
  @register @id()

  onCreated: ->
    super arguments...

    @sprite = new ComputedField =>
      @interface.getEditorForActiveFile()?.spriteData()
    
    @layers = new ComputedField =>
      return unless sprite = @sprite()
      layers = _.cloneDeep sprite.layers or []

      # Attach layer index to layer.
      layer.index = index for layer, index in layers when layer

      # Remove removed layers.
      _.pull layers, null

      _.sortBy layers, (layer) => -layer.origin?.z or 0

    @paintHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Paint

  activeClass: ->
    layer = @currentData()
    'active' if layer.index is @paintHelper.layerIndex()

  depth: ->
    layer = @currentData()
    layer.origin?.z or 0

  placeholderName: ->
    layer = @currentData()
    "Layer #{layer.index}"

  layerThumbnail: ->
    layer = @currentData()
    sprite = _.clone @sprite()
    return unless sprite.layers?[layer.index]

    # Show only the single layer.
    sprite.layers = [sprite.layers[layer.index]]

    sprite

  # Events

  events: ->
    super(arguments...).concat
      'click .thumbnail': @onClickThumbnail
      'change .depth-input': @onChangeDepth
      'change .name-input': @onChangeLayer
      'click .add-layer-button': @onClickAddLayerButton

  onClickThumbnail: (event) ->
    layer = @currentData()
    @paintHelper.setLayerIndex layer.index

  onChangeDepth: (event) ->
    layer = @currentData()
    depth = parseFloat $(event.target).val()

    # HACK: Replace the number back since it won't update by itself (probably since it's the edited input).
    $(event.target).val depth

    sprite = @sprite()

    if _.isNaN depth
      # Remove the layer.
      LOI.Assets.Sprite.removeLayer sprite._id, layer.index

    else
      # Change the depth of the layer.
      LOI.Assets.Sprite.updateLayer sprite._id, layer.index, origin: z: depth

  onChangeLayer: (event) ->
    layer = @currentData()
    $layer = $(event.target).closest('.layer')

    newData =
      name: $layer.find('.name-input').val()
      
    sprite = @sprite()
    LOI.Assets.Sprite.updateLayer sprite._id, layer.index, newData

  onClickAddLayerButton: (event) ->
    sprite = @sprite()

    index = sprite.layers.length or 0
    maxDepth = _.max (layer.origin?.z or 0 for layer in sprite.layers)

    LOI.Assets.Sprite.updateLayer sprite._id, index, origin: z: maxDepth + 1
