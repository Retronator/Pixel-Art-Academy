AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Layers extends FM.View
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Layers'
  @register @id()

  onCreated: ->
    super arguments...

    @mesh = new ComputedField =>
      @interface.getLoaderForActiveFile()?.meshData()

    @meshCanvas = new ComputedField =>
      @interface.getEditorForActiveFile()
    ,
      (a, b) => a is b

    @selection = new ComputedField =>
      @interface.getHelperForActiveFile LOI.Assets.MeshEditor.Helpers.Selection

    @objectIndex = new ComputedField =>
      @selection()?.objectIndex()

    @object = new ComputedField =>
      @mesh()?.objects.get @objectIndex()

    @layers = new ComputedField =>
      return unless object = @object()

      layers = object.layers.getAll()
      _.sortBy layers, (layer) => -layer.order() or 0

    @paintHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Paint

  activeClass: ->
    layer = @currentData()
    'active' if layer.index is @paintHelper.layerIndex()

  order: ->
    layer = @currentData()
    layer.order() or 0

  visibleCheckedAttribute: ->
    layer = @currentData()
    checked: true if layer.visible() ? true

  placeholderName: ->
    layer = @currentData()
    "Layer #{layer.index}"

  layerThumbnail: ->
    layer = @currentData()

    object = layer.object
    mesh = object.mesh

    return unless meshCanvas = @meshCanvas()
    cameraAngleIndex = meshCanvas.cameraAngleIndex()

    # Generate layer pixels.
    {bounds, pixels} = layer.getSpriteBoundsAndPixelsForCameraAngle cameraAngleIndex
    layer = {pixels}

    # The sprite expects materials as a map instead of an array.
    materials = mesh.materials.getAllAsIndexedMap()

    new LOI.Assets.Sprite
      palette: _.pick mesh.palette, ['_id']
      layers: [layer]
      materials: materials
      bounds: bounds

  nameDisabledAttribute: ->
    # Disable name editing until the layer is active.
    layer = @currentData()
    disabled: true unless layer.index is @paintHelper.layerIndex()

  showAddButton: ->
    # We can add a layer if we have an object.
    @object()

  showRemoveButton: ->
    # We can remove a layer if the currently selected layer exists.
    @object()?.layers.get @paintHelper.layerIndex()

  # Events

  events: ->
    super(arguments...).concat
      'click .thumbnail, click .name': @onClickLayer
      'change .order-input': @onChangeOrder
      'change .name-input, change .visible-checkbox': @onChangeLayer
      'click .add-button': @onClickAddButton
      'click .remove-button': @onClickRemoveButton

  onClickLayer: (event) ->
    layer = @currentData()
    @paintHelper.setLayerIndex layer.index

  onChangeOrder: (event) ->
    layer = @currentData()
    order = parseFloat $(event.target).val()

    # HACK: Replace the number back since it won't update by itself (probably since it's the edited input).
    $(event.target).val order

    layer.order order

  onChangeLayer: (event) ->
    layer = @currentData()
    $layer = $(event.target).closest('.layer')

    layer.name $layer.find('.name-input').val()
    layer.visible $layer.find('.visible-checkbox').is(':checked')

  onClickAddButton: (event) ->
    object = @object()

    layers = object.layers.getAll()

    if layers?.length
      order = 1 + (_.max(layer.order() for layer in layers) or 0)

    else
      order = 0

    index = object.layers.insert {order}

    @paintHelper.setLayerIndex index

  onClickRemoveButton: (event) ->
    object = @object()
    object.layers.remove @paintHelper.layerIndex()
