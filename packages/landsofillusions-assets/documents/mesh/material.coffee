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

    # Signal change of the material.
    @_updatedDependency.changed()
    @materials.contentUpdated()

  toUniversalMaterialOptions: -> @constructor.createUniversalMaterialOptions this
  toPhysicalMaterialParameters: (palette) -> @constructor.createPhysicalMaterialParameters this, palette
