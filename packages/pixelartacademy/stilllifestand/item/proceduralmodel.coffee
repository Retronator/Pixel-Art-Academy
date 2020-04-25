AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StillLifeStand.Item.ProceduralModel extends PAA.StillLifeStand.Item
  @id: -> 'PixelArtAcademy.StillLifeStand.Item.Model'

  @initialize: ->
    super arguments...

    parent = @

    class @RenderObject extends PAA.StillLifeStand.Item.RenderObject
      constructor: (@parentItem) ->
        super arguments...

        @material = new THREE.MeshPhysicalMaterial color: 0xaaaaaa
        @geometry = @createGeometry()

        @mesh = new THREE.Mesh @geometry, @material
        @mesh.receiveShadow = true
        @mesh.castShadow = true

        @add @mesh

      createGeometry: -> @parentItem.createGeometry.call @

    class @PhysicsObject extends PAA.StillLifeStand.Item.PhysicsObject
      constructor: ->
        super arguments...
        @initialize()

      createCollisionShape: ->
        collisionShape = @parentItem.createCollisionShape.call @
        collisionShape.setMargin PAA.StillLifeStand.Item.roughEdgeMargin
        collisionShape

  constructor: ->
    super arguments...

    @renderObject = new @constructor.RenderObject @
    @physicsObject = new @constructor.PhysicsObject @

    @options.onInitialized @

  createGeometry: ->
    throw new AE.NotImplementedException "Still life procedural model must provide a geometry."

  createCollisionShape: ->
    throw new AE.NotImplementedException "Still life procedural model must provide a collision shape."
