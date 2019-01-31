AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.Mesh.Object.Layer
  constructor: (@layers, @index, data) ->
    @object = @layers.parent
    
    @_updatedDependency = new Tracker.Dependency
    
    for field in ['name', 'visible', 'order']
      @[field] = new LOI.Assets.Mesh.ValueField @, field, data[field]

    @pictures = new LOI.Assets.Mesh.ArrayField @, 'pictures', data.pictures, @constructor.Picture

  toPlainObject: ->
    plainObject = {}

    @[field].save plainObject for field in ['name', 'visible', 'order', 'pictures']

    plainObject

  depend: ->
    @_updatedDependency.depend()

  contentUpdated: ->
    @_updatedDependency.changed()
    @layers.contentUpdated()

  getPictureForCameraAngleIndex: (cameraAngleIndex) ->
    picture = @pictures.get cameraAngleIndex
    return picture if picture
    
    # Picture hasn't been created yet, so insert and retry.
    @pictures.insert {}, cameraAngleIndex
    @pictures.get cameraAngleIndex
