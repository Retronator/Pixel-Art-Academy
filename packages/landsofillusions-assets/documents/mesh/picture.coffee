AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.Mesh.Picture
  constructor: (@pictures, @index, data) ->
    @layer = @pictures.parent

    @_updatedDependency = new Tracker.Dependency

    @cameraAngleIndex = data.cameraAngle
    
  toPlainObject: ->
    plainObject =
      cameraAngle: @cameraAngleIndex

    plainObject

  depend: ->
    @_updatedDependency.depend()

  contentUpdated: ->
    @_updatedDependency.changed()
    @objects.contentUpdated()

  cameraAngle: ->
    @layer.object.mesh.cameraAngles.get @cameraAngleIndex

  addPixel: (pixel) ->
    
