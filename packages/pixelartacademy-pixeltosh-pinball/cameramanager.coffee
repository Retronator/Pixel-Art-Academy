AE = Artificial.Everywhere
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.CameraManager
  @pixelSize = 0.5 / 180 # m/px
  
  constructor: (@pinball) ->
    halfWidth = Pinball.SceneManager.playfieldWidth / 2
    halfHeight = halfWidth / Pinball.RendererManager.aspectRatio
    
    @_orthographicCamera = new THREE.OrthographicCamera -halfWidth, halfWidth, halfHeight, -halfHeight, 0, 2
    @_orthographicCamera.position.set halfWidth, 1, halfHeight
    @_orthographicCamera.rotation.set -Math.PI / 2, 0, 0
    
    @_perspectiveCamera = new THREE.PerspectiveCamera 60, Pinball.RendererManager.aspectRatio, 0.1, 10
    @_perspectiveCamera.position.set halfWidth, 0.2, 2 * Pinball.SceneManager.shortPlayfieldHeight
    
    @camera = new AE.ReactiveWrapper @_orthographicCamera
