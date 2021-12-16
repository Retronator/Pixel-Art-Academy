LOI = LandsOfIllusions

class LOI.Engine.Materials
  @_cache = {}
  @_cacheDependency = new Tracker.Dependency

  @getMaterial: (materialId, options = {}) ->
    @_cache[materialId] ?= []

    # Try to find a material with these options in the cache.
    # The documents (objects with an ID) are compared only to the ID.
    searchOptions = _.clone options
    searchOptions[key] = value._id for key, value of searchOptions when value?._id

    materialEntry = _.find @_cache[materialId], (materialEntry) => _.isEqual materialEntry.options, searchOptions
    return materialEntry.material if materialEntry

    # We need to create the material.
    materialClass = LOI.Engine.Materials.Material.getClassForId materialId
    material = new materialClass options

    # Deeply clone search options so we definitely have an unchanging key to search by.
    searchOptions = _.cloneDeep searchOptions

    @_cache[materialId].push {material, options: searchOptions}
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
