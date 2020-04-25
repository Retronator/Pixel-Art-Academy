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
