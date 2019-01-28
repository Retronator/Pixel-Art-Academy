AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.Mesh.Layer
  constructor: (@layers, @index, data) ->
    @object = @layers.parent
    
    @_updatedDependency = new Tracker.Dependency
    
    for field in ['name', 'visible', 'order']
      @[field] = new LOI.Assets.Mesh.ValueField @, field, data[field]

    @pictures = new LOI.Assets.Mesh.ArrayField @, 'pictures', data.layers, LOI.Assets.Mesh.Picture

  toPlainObject: ->
    plainObject = {}

    @[field].save plainObject for field in ['name', 'visible', 'order', 'pictures']

    plainObject

  depend: ->
    @_updatedDependency.depend()

  contentUpdated: ->
    @_updatedDependency.changed()
    @layers.contentUpdated()

  getPictureForCameraAngle: (cameraAngleIndex) ->
    picture = _.find @pictures.getAll(), (picture) => picture.cameraAngle()?.index is cameraAngleIndex
    return picture if picture
    
    # Picture hasn't been created yet, so insert it and retry.
    @pictures.insert cameraAngle: cameraAngleIndex
    @getPictureForCameraAngle cameraAngleIndex
