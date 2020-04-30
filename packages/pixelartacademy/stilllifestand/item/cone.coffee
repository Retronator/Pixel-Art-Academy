AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StillLifeStand.Item.Cone extends PAA.StillLifeStand.Item.ProceduralModel
  @id: -> 'PixelArtAcademy.StillLifeStand.Item.Cone'
  @initialize()

  createGeometry: ->
    properties = @parentItem.data.properties
    new THREE.ConeBufferGeometry properties.radius, properties.height, 32, 32

  createCollisionShape: ->
    properties = @parentItem.data.properties
    margin = PAA.StillLifeStand.Item.roughEdgeMargin

    collisionShape = new Ammo.btConeShape properties.radius - 2 * margin, properties.height - 2 * margin
    collisionShape

  addDragObjects: ->
    {radius, height} = @parentItem.data.properties
    diameter = 2 * radius

    yArea = Math.PI * radius ** 2
    xzArea = diameter * height / 2

    yDragCoefficient = 0.5 / (((height ** 2) / (diameter ** 2)) + 1)
    xzDragCoefficient = 0.47

    yLinearDragFactor = yArea * yDragCoefficient
    xzLinearDragFactor = xzArea * xzDragCoefficient

    longerSide = Math.max diameter, height
    shorterSide = Math.min diameter, height
    angularArea = longerSide * diameter
    angularDragCoefficient = 1 / ((shorterSide / longerSide) + 1)
    angularDragFactor = (longerSide / 2) ** 3 * angularArea * angularDragCoefficient

    @addDragObject
      position: new THREE.Vector3()
      linearDragFactor: new THREE.Vector3 xzLinearDragFactor, yLinearDragFactor, xzLinearDragFactor
      angularDragFactor: new THREE.Vector3 angularDragFactor, 0, angularDragFactor
