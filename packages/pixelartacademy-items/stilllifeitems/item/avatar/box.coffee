AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Items.StillLifeItems.Item.Avatar.Box extends PAA.Items.StillLifeItems.Item.Avatar.ProceduralModel
  @initializeEngineObjectClasses()

  createGeometry: ->
    size = @avatar.properties.size
    new THREE.BoxGeometry size.x, size.y, size.z

  createCollisionShape: ->
    size = @avatar.properties.size
    new Ammo.btBoxShape new Ammo.btVector3 size.x / 2, size.y / 2, size.z / 2

  addDragObjects: ->
    @addDragObject
      position: new THREE.Vector3()
      size: @avatar.properties.size
