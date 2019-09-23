LOI = LandsOfIllusions

class LOI.Engine.Materials
  @_cache = {}
  @_cacheDependency = new Tracker.Dependency

  @getMaterial: (materialId, options = {}) ->
    @_cache[materialId] ?= []

    # Try to find a material with these options in the cache.
    materialEntry = _.find @_cache[materialId], (materialEntry) => _.isEqual materialEntry.options, options
    return materialEntry.material if materialEntry

    # We need to create the material. Create a clone of options so we definitely have an unchanging key to search by.
    options = _.cloneDeep options

    materialClass = LOI.Engine.Materials.Material.getClassForId materialId
    material = new materialClass options

    @_cache[materialId].push {material, options}
    @_cacheDependency.changed()

    # Return the material.
    material

  @depend: ->
    @_cacheDependency.depend()

    for materialId, materialEntries of @_cache
      for materialEntry in materialEntries
        materialEntry.material.depend()

    # Also depend on loaded textures.
    LOI.Engine.Textures.Sprite.depend()
