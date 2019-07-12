LOI = LandsOfIllusions

class LOI.Engine.Materials
  @_cache = {}

  @getMaterial: (materialId, options) ->
    @_cache[materialId] ?= []

    # Try to find a material with these options in the cache.
    materialEntry = _.find @_cache[materialId], (materialEntry) => _.isEqual materialEntry.options, options
    return materialEntry.material if materialEntry

    # We need to create the material.
    materialClass = LOI.Engine.Materials.Material.getClassForId materialId
    material = new materialClass options

    # Create a clone of options so we definitely have an unchanging key to search by.
    options = _.cloneDeep options

    @_cache[materialId].push {material, options}

    # Return the material.
    material
