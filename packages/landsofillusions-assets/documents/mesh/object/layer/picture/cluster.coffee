AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Assets.Mesh.Object.Layer.Picture.Cluster
  constructor: (@picture, id, data) ->
    @_updatedDependency = new Tracker.Dependency
    @id = parseInt id

    @_setSourceCoordinates data.sourceCoordinates

  toPlainObject: ->
    sourceCoordinates: @sourceCoordinates

  depend: ->
    @_updatedDependency.depend()

  updateSourceCoordinates: (sourceCoordinates) ->
    @_setSourceCoordinates sourceCoordinates
    
    # Signal change of the cluster.
    @_updatedDependency.changed()
    @picture.contentUpdated()

  _setSourceCoordinates: (sourceCoordinates) ->
    @sourceCoordinates = sourceCoordinates
    @properties = @picture.getMapValuesForPixel sourceCoordinates.x, sourceCoordinates.y
