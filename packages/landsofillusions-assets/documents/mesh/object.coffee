AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.Mesh.Object
  constructor: (@objects, @index, data) ->
    @mesh = @objects.parent
    
    @_updatedDependency = new Tracker.Dependency
    
    for field in ['name', 'visible', 'solver']
      @[field] = new LOI.Assets.Mesh.ValueField @, field, data[field]

    @layers = new LOI.Assets.Mesh.ArrayField @, 'layers', data.layers, LOI.Assets.Mesh.Layer

  toPlainObject: ->
    plainObject = {}
    @[field].save plainObject for field in ['name', 'visible', 'solver', 'layers']

    plainObject

  depend: ->
    @_updatedDependency.depend()

  contentUpdated: ->
    @_updatedDependency.changed()
    @objects.contentUpdated()
