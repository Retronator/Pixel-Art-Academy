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
      layer.index = index for layer, index in layers

      _.sortBy layers, (layer) => layer.origin?.z or 0

  depth: ->
    layer = @currentData()
    layer.origin?.z or 0

  placeholderName: ->
    layer = @currentData()
    layer.name or "Layer #{layer.index}"

  # Events

  events: ->
    super(arguments...).concat
      'change .depth-input': @onChangeDepth
      'change .name-input': @onChangeLayer
      'click .add-layer-button': @onClickAddLayerButton

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
      LOI.Assets.Sprite.updateLayer sprite._id, index, origin: z: depth

  onChangeLayer: (event) ->
    layer = @currentData()
    $layer = $(event.target).closest('.layer')

    newData =
      # We null the name if it's an empty string
      name: $layer.find('.name-input').val() or null
      
    sprite = @sprite()
    LOI.Assets.Sprite.updateLayer sprite._id, layer.index, newData

  onClickAddLayerButton: (event) ->
    sprite = @sprite()

    index = sprite.layers.length or 0
    maxDepth = _.max (layer.origin?.z or 0 for layer in sprite.layers)

    LOI.Assets.Sprite.updateLayer sprite._id, index, origin: z: maxDepth + 1
