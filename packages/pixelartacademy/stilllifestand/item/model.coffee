AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StillLifeStand.Item.Model extends PAA.StillLifeStand.Item
  @id: -> 'PixelArtAcademy.StillLifeStand.Item.Model'
  @initialize()

  constructor: ->
    super arguments...

    @renderObject = new @constructor.RenderObject @
    @physicsObject = new @constructor.PhysicsObject @

    @constructor.Loader.load @data.properties.path, (data) =>
      @physicsObject.initialize data.collisionShape, data.dragObjects
      @renderObject.initialize data.renderMesh

      # Signal that we have finished initialization and the model can be added to the scene.
      @options.onInitialized @

  class @RenderObject extends PAA.StillLifeStand.Item.RenderObject
    initialize: (mesh) ->
      @mesh = mesh.clone()

      @material = @mesh.material
      @geometry = @mesh.geometry

      @add @mesh

  class @PhysicsObject extends PAA.StillLifeStand.Item.PhysicsObject
    initialize: (@_collisionShape, dragObjects) ->
      super arguments...

      @addDragObject dragObject for dragObject in dragObjects

    createCollisionShape: ->
      # Simply return the loaded collision shape.
      @_collisionShape
