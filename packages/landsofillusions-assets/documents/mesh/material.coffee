LOI = LandsOfIllusions

class LOI.Assets.Mesh.Material
  @createUniversalMaterialOptions: (material) ->
    return _.defaultsDeep {}, material, LOI.Engine.Materials.UniversalMaterial.defaults

  constructor: (@materials, @index, data) ->
    @_updatedDependency = new Tracker.Dependency

    @sourceData = {}
    @update data

  toPlainObject: ->
    _.clone @sourceData

  depend: ->
    @_updatedDependency.depend()

  update: (update) ->
    # Update source data and the object itself.
    _.merge @sourceData, update
    _.merge @, update

    # Delete keys without a value so that defaults will kick in (they have to be undefined, not null).
    for key, value of @sourceData when not value?
      delete @sourceData[key]
      delete @[key]

    # Signal change of the material.
    @_updatedDependency.changed()
    @materials.contentUpdated()

  toUniversalMaterialOptions: -> @constructor.createUniversalMaterialOptions this
  toPhysicalMaterialParameters: (palette) -> @constructor.createPhysicalMaterialParameters this, palette
