AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Assets.Mesh.LayerProperties
  @maxLayerAtlasSize: 4096

  constructor: (@mesh) ->
    @layerProperties = []
    @indicesByObjectAndLayerIndex = []

    @_updatedDependency = new Tracker.Dependency

    @texture = new LOI.Engine.Textures.LayerProperties
    @layerAtlasSize = new ReactiveField width: 0, height: 0

    # Update layer properties. We need to do it in an autorun to depend on layer changes.
    Tracker.nonreactive =>
      Tracker.autorun =>
        @update()
        @texture.update @

  update: ->
    # Get all non-empty layers.
    layers = []

    objects = @mesh.objects.getAllWithoutUpdates() or []

    for object in objects
      objectLayers = object.layers.getAllWithoutUpdates() or []

      for layer in objectLayers
        if picture = layer.pictures.get 0
          if picture.bounds()
            layers.push layer

    # Extract layer properties.
    @layerProperties = []

    for layer in layers
      picture = layer.pictures.get 0
      bounds = picture.bounds()

      @layerProperties.push
        layerIndex: layer.index
        objectIndex: layer.object.index
        width: bounds.width
        height: bounds.height

    # Sort by width for better atlas packing.
    @layerProperties.sort (a, b) => b.width - a.width

    # Calculate positions in the atlas.
    layerAtlasWidth = @layerProperties[0]?.width or 0
    layerAtlasHeight = 0
    currentLeft = 0
    currentTop = 0

    for layer, layerIndex in @layerProperties
      # If the layer can't fit in the current column, start a new column.
      if currentTop + layer.height > @constructor.maxLayerAtlasSize
        currentLeft = layerAtlasWidth
        currentTop = 0
        layerAtlasWidth += layer.width

      layer.atlasPositionX = currentLeft
      layer.atlasPositionY = currentTop

      # Move down.
      currentTop += layer.height

      # Update max height.
      layerAtlasHeight = Math.max layerAtlasHeight, currentTop

    # Update how big the layer atlases need to be.
    @layerAtlasSize width: layerAtlasWidth, height: layerAtlasHeight

    # Index for querying by layer.
    @indicesByObjectAndLayerIndex = []

    for layerPropertiesEntry, index in @layerProperties
      @indicesByObjectAndLayerIndex[layerPropertiesEntry.objectIndex] ?= []
      @indicesByObjectAndLayerIndex[layerPropertiesEntry.objectIndex][layerPropertiesEntry.layerIndex] = index

    @_updatedDependency.changed()

  getIndex: (layer) ->
    @_updatedDependency.depend()
    @indicesByObjectAndLayerIndex[layer.object.index]?[layer.index]

  getPropertiesForLayer: (layer) ->
    @layerProperties[@getIndex layer]

  getAll: ->
    @_updatedDependency.depend()
    @layerProperties
