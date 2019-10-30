AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Pages.Admin.Characters.AnimationsTest.RendererManager
  @renderWidth = 250
  @renderHeight = 100
  @sceneWidth = 5

  constructor: (@parent) ->
    @renderer = new THREE.WebGLRenderer
    @renderer.setSize @constructor.renderWidth, @constructor.renderHeight

    halfWidth = @constructor.sceneWidth / 2
    halfHeight = halfWidth * @constructor.renderHeight / @constructor.renderWidth
    @targetOffset = (@parent.charactersCount - 1) / 2

    #@camera = new THREE.OrthographicCamera -halfWidth, halfWidth, halfHeight, -halfHeight, 0, 20
    @camera = new THREE.PerspectiveCamera 25, @constructor.renderWidth / @constructor.renderHeight, 0.1, 20
    @camera.position.set @targetOffset, 1.5, 8.1

    @_position = new THREE.Vector3
    @_target = new THREE.Vector3 @targetOffset, 1.5, 0
    @_up = new THREE.Vector3 0, 1, 0

  draw: (appTime) ->
    angle = appTime.totalAppTime / Math.PI
    distance = 8.1

    @_position.set Math.cos(angle) * distance + @targetOffset, 1.5, Math.sin(angle)  * distance

    #@camera.matrix.lookAt @_position, @_target, @_up
    #@camera.matrix.setPosition @_position
    #@camera.matrix.decompose @camera.position, @camera.quaternion, @camera.scale

    sceneManager = @parent.sceneManager()
    scene = sceneManager.scene()

    @renderer.setClearColor 0x222222, 1
    @renderer.render scene, @camera

  destroy: ->
    @renderer.dispose()
