AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.Mesh.Material
  constructor: (@materials, @index, data) ->
    @_updatedDependency = new Tracker.Dependency

    @sourceData = {}
    @update data

  toPlainObject: ->
    @sourceData

  depend: ->
    @_updatedDependency.depend()

  update: (update) ->
    # Update source data and the object itself.
    _.merge @sourceData, update
    _.merge @, update

    # Signal change of the material.
    @_updatedDependency.changed()
    @materials.contentUpdated()

  _createVector: (vectorData = {}) ->
    new THREE.Vector3 vectorData.x or 0, vectorData.y or 0, vectorData.z or 0
