AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Layers extends FM.View
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Layers'
  @register @id()

  onCreated: ->
    super arguments...

    @asset = new ComputedField =>
      @interface.getEditorForActiveFile()?.assetData()
    
    @layers = new ComputedField =>
      return unless asset = @asset()
      layers = _.clone asset.layers or []

      # Attach layer index to layer.
      for layer, index in layers when layer
        layers[index] = _.extend {index}, layer

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

  visibleCheckedAttribute: ->
    layer = @currentData()
    checked: true if layer.visible ? true

  placeholderName: ->
    layer = @currentData()
    "Layer #{layer.index}"

  layerThumbnail: ->
    layer = @currentData()
    return unless asset = _.clone @asset()
    return unless asset.layers?[layer.index]

    # Show only the single layer.
    asset.layers = [asset.layers[layer.index]]

    # Keep the layer visible.
    asset.layers[0] = _.clone asset.layers[0]
    asset.layers[0].visible = true

    asset

  showAddButton: ->
    # We can add a layer if we have a asset set for the camera angle.
    @asset()

  showRemoveButton: ->
    # We can remove a layer if the currently selected layer exists.
    @asset()?.layers?[@paintHelper.layerIndex()]

  # Events

  events: ->
    super(arguments...).concat
      'click .thumbnail': @onClickThumbnail
      'change .depth-input': @onChangeDepth
      'change .name-input, change .visible-checkbox': @onChangeLayer
      'click .add-button': @onClickAddButton
      'click .remove-button': @onClickRemoveButton

  onClickThumbnail: (event) ->
    layer = @currentData()
    @paintHelper.setLayerIndex layer.index

  onChangeDepth: (event) ->
    layer = @currentData()
    depth = parseFloat $(event.target).val()

    # HACK: Replace the number back since it won't update by itself (probably since it's the edited input).
    $(event.target).val depth

    asset = @asset()

    if _.isNaN depth
      # Remove the layer.
      LOI.Assets.Sprite.removeLayer asset._id, layer.index

    else
      # Change the depth of the layer.
      LOI.Assets.Sprite.updateLayer asset._id, layer.index, origin: z: depth

  onChangeLayer: (event) ->
    layer = @currentData()
    $layer = $(event.target).closest('.layer')

    newData =
      name: $layer.find('.name-input').val()
      visible: $layer.find('.visible-checkbox').is(':checked')
      
    asset = @asset()
    LOI.Assets.Sprite.updateLayer asset._id, layer.index, newData

  onClickAddButton: (event) ->
    asset = @asset()

    index = asset.layers?.length or 0

    if asset?.layers?.length
      depth = 1 + (_.max(layer.origin.z for layer in asset.layers when layer?.origin?.z?) or 0)

    else
      depth = 0

    LOI.Assets.Sprite.updateLayer asset._id, index, origin: z: depth

    @paintHelper.setLayerIndex index

  onClickRemoveButton: (event) ->
    asset = @asset()

    LOI.Assets.Sprite.removeLayer asset._id, @paintHelper.layerIndex()
