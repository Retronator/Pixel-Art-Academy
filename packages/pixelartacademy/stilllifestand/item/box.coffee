AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StillLifeStand.Item.Box extends PAA.StillLifeStand.Item.ProceduralModel
  @id: -> 'PixelArtAcademy.StillLifeStand.Item.Box'
  @initialize()

  createGeometry: ->
    size = @parentItem.data.properties.size
    new THREE.BoxBufferGeometry size.x, size.y, size.z

  createCollisionShape: ->
    size = @parentItem.data.properties.size
    new Ammo.btBoxShape new Ammo.btVector3 size.x / 2, size.y / 2, size.z / 2

  addDragObjects: ->
    @addDragObject
      position: new THREE.Vector3()
      size: @parentItem.data.properties.size
