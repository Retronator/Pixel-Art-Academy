AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Items.StillLifeItems.Item.Avatar.Model extends PAA.Items.StillLifeItems.Item.Avatar
  initialize: ->
    @_renderObject = new @constructor.RenderObject @
    @_physicsObject = new @constructor.PhysicsObject @

    @constructor.Loader.load @properties.path, (data) =>
      @_physicsObject.initialize data.collisionShape, data.dragObjects
      @_renderObject.initialize data.renderMesh

      # Signal that we have finished initialization and the model can be added to the scene.
      @initialized true

  class @RenderObject extends PAA.Items.StillLifeItems.Item.Avatar.RenderObject
    initialize: (mesh) ->
      @mesh = mesh.clone()

      @material = @mesh.material
      @geometry = @mesh.geometry

      @add @mesh

  class @PhysicsObject extends PAA.Items.StillLifeItems.Item.Avatar.PhysicsObject
    initialize: (@_collisionShape, dragObjects) ->
      super arguments...

      @addDragObject dragObject for dragObject in dragObjects

    createCollisionShape: ->
      # Simply return the loaded collision shape.
      @_collisionShape
