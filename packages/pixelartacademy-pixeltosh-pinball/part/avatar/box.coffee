AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Part.Avatar.Box extends Pinball.Part.Avatar.Shape
  @detectShape: (pixelArtEvaluation, properties) ->
    return unless pixelArtEvaluation.layers[0].points.length
    
    new @ pixelArtEvaluation, properties
  
  createPhysicsDebugGeometry: ->
    new THREE.BoxBufferGeometry @width, @height, @depth

  createCollisionShape: ->
    new Ammo.btBoxShape new Ammo.btVector3 @width / 2, @height / 2, @depth / 2

  yPosition: -> @height / 2
