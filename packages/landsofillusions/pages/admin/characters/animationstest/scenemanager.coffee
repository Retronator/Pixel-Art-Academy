AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Pages.Admin.Characters.AnimationsTest.SceneManager
  constructor: (@parent) ->
    scene = new THREE.Scene()
    scene.manager = @
    @scene = new AE.ReactiveWrapper scene

    @sceneObjectsAddedDependency = new Tracker.Dependency

    @directionalLights = new ReactiveField []
    
    ambientLight = new THREE.AmbientLight 0xffffff, 0.5
    scene.add ambientLight

    interiorLighting = new THREE.DirectionalLight 0xffffff, 0.5
    interiorLighting.position.set 0, 3.5, 0.4
    scene.add interiorLighting
    
    sun = new THREE.DirectionalLight 0xffffff, 1.5
    sun.position.set 100, 100, 100
    scene.add sun

    @directionalLights [interiorLighting, sun]

    @groundMoveSpeed = 0
    
    @gridHelper = new THREE.GridHelper 100, 100, 0x333333, 0x333333
    scene.add @gridHelper

    # Apply uniforms to new objects when they get added.
    @parent.autorun (computation) =>
      return unless uniforms = @getUniforms()
      @sceneObjectsAddedDependency.depend()

      scene.traverse (object) =>
        return unless object.mainMaterial?.uniforms and not object.mainMaterial.uniformsInitialized
        object.mainMaterial.uniformsInitialized = true

        @_applyUniformsToMaterial uniforms, object.mainMaterial

    # Apply uniforms to all objects when uniforms change.
    @parent.autorun (computation) =>
      return unless uniforms = @getUniforms()

      scene.traverse (object) =>
        return unless object.mainMaterial?.uniforms

        @_applyUniformsToMaterial uniforms, object.mainMaterial

      @scene.updated()

  getAllChildren: (filterParameter) ->
    filter = _.filterFunction filterParameter
    scene = @scene.withUpdates()

    children = []

    addAllChildren = (item) ->
      children.push item if filter item
      addAllChildren child for child in item.children

    addAllChildren scene
    children

  getUniforms: ->
    RenderManager = LOI.Pages.Admin.Characters.AnimationsTest.RendererManager

    renderSize: new THREE.Vector2 RenderManager.renderWidth, RenderManager.renderHeight
    directionalOpaqueShadowMap: []
    directionalShadowColorMap: []
    smoothShading: LOI.settings.graphics.smoothShading.value()
    colorQuantizationFactor: (LOI.settings.graphics.colorQuantizationLevels.value() or 1) - 1

  addedSceneObjects: ->
    @sceneObjectsAddedDependency.changed()
    @scene.updated()

  _applyUniformsToMaterial: (uniforms, material) ->
    for uniform, value of uniforms
      if material.uniforms[uniform]
        material.uniforms[uniform].value = value
        material.needsUpdate = true

  update: (appTime) ->
    return unless direction = @parent.direction()

    # Move the ground.
    groundMoveTargetSpeed = if @parent.testAnimationName() is 'Walk 50' then 1.75 else 0

    deltaGround = Math.sign groundMoveTargetSpeed - @groundMoveSpeed
    changeGround = deltaGround * 6

    @groundMoveSpeed += changeGround * appTime.elapsedAppTime
    @groundMoveSpeed = _.clamp @groundMoveSpeed, 0, 1.75

    distance = direction.clone().multiplyScalar @groundMoveSpeed * appTime.elapsedAppTime

    @gridHelper.position.sub distance
    @gridHelper.position.x = @gridHelper.position.x % 1
    @gridHelper.position.z = @gridHelper.position.z % 1
