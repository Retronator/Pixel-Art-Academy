AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Items.StillLifeItems.Item.Avatar.ProceduralModel extends PAA.Items.StillLifeItems.Item.Avatar
  @initializeEngineObjectClasses: ->
    class @RenderObject extends PAA.Items.StillLifeItems.Item.Avatar.RenderObject
      constructor: (@avatar) ->
        super arguments...

        @material = new THREE.MeshPhysicalMaterial
          color: 0xaaaaaa
          reflectivity: 0
          metalness: 0
          roughness: 1

        @geometry = @createGeometry()

        @mesh = new THREE.Mesh @geometry, @material
        @initializeMesh @mesh

      createGeometry: -> @avatar.createGeometry.call @

    class @PhysicsObject extends PAA.Items.StillLifeItems.Item.Avatar.PhysicsObject
      constructor: (@avatar) ->
        super arguments...

        @addDragObjects()

        @initialize()

      createCollisionShape: ->
        collisionShape = @avatar.createCollisionShape.call @
        margin = @avatar.collisionShapeMargin.call @
        collisionShape.setMargin margin if margin?
        collisionShape

      addDragObjects: -> @avatar.addDragObjects.call @

  initialize: ->
    @_renderObject = new @constructor.RenderObject @
    @_physicsObject = new @constructor.PhysicsObject @

    @initialized true

  createGeometry: ->
    throw new AE.NotImplementedException "Still life procedural model must provide a geometry."

  createCollisionShape: ->
    throw new AE.NotImplementedException "Still life procedural model must provide a collision shape."

  addDragObjects: -> # Implement to add drag objects.

  collisionShapeMargin: -> PAA.Items.StillLifeItems.Item.Avatar.roughEdgeMargin
