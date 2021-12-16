AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Assets.Mesh.MaterialProperties
  constructor: (@mesh) ->
    @materialProperties = []
    @indicesByPaletteColor = {}
    @indicesByMaterialIndex = {}

    @_updatedDependency = new Tracker.Dependency

    @initialize()

  initialize: ->
    # Build the initial list from existing mesh data.
    objects = @mesh.objects.getAllWithoutUpdates()
    return unless objects?.length

    for object in objects
      layers = object.layers.getAllWithoutUpdates()

      if layers?.length
        for layer in layers
          clusters = layer.clusters.getAllWithoutUpdates()

          if clusters?
            for clusterId, cluster of clusters
              @register cluster.material()

  register: (materialProperties) ->
    # See if we already have these properties.
    existingIndex = @getIndex materialProperties
    return if existingIndex?

    # We don't have these properties yet, add them.
    newIndex = @materialProperties.length
    @materialProperties.push materialProperties

    if paletteColor = materialProperties.paletteColor
      @indicesByPaletteColor[paletteColor.ramp] ?= {}
      @indicesByPaletteColor[paletteColor.ramp][paletteColor.shade] = newIndex

    else if materialProperties.materialIndex?
      @indicesByMaterialIndex[materialProperties.materialIndex] = newIndex

    else
      throw new AE.NotImplementedException "Material properties", materialProperties, "are not supported."

    # Notify waiting callers that we have a new index.
    @_updatedDependency.changed()

  getIndex: (materialProperties) ->
    if paletteColor = materialProperties.paletteColor
      return @indicesByPaletteColor[paletteColor.ramp]?[paletteColor.shade]

    else if materialProperties.materialIndex?
      return @indicesByMaterialIndex[materialProperties.materialIndex]

    # We didn't find this material properties, so make the caller reactively wait until we get them registered.
    @_updatedDependency.depend()
    null

  getAll: ->
    @_updatedDependency.depend()
    @materialProperties
