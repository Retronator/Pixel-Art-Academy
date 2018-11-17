AE = Artificial.Everywhere
AS = Artificial.Spectrum

class AS.AnimatedMesh extends AS.RenderObject
  constructor: (@options) ->
    super arguments...

    @data = new ReactiveField @options.data
    @texture = new ReactiveField @options.texture

    # Load data and texture if provided with their URLs.
    if @options.dataUrl
      $.getJSON @options.dataUrl, (data) =>
        @data data

    if @options.textureUrl
      texture = new THREE.TextureLoader().load @options.textureUrl
      texture.magFilter = THREE.NearestFilter
      texture.minFilter = THREE.NearestFilter
      @texture texture

    # Create material from texture.
    @_material = @options.material or new THREE.MeshBasicMaterial
      transparent: true
      side: THREE.DoubleSide
      depthWrite: false

    @_depthMaterial = new THREE.MeshDepthMaterial
      depthPacking: THREE.RGBADepthPacking
      alphaTest: 0.5

    @materials = new AE.ReactiveWrapper
      main: @_material
      depth: @_depthMaterial

    # Reactively update the texture.
    @autorun (computation) =>
      @_material.map = @texture()
      @_material.needsUpdate = true

      @_depthMaterial.map = @texture()
      @_depthMaterial.needsUpdate = true

      @materials.updated()

    # Create creature objects.
    @creature = new ComputedField =>
      return unless data = @data()

      new AS.Creature data
    ,
      true

    @creatureManager = new ComputedField =>
      return unless creature = @creature()
      data = @data()

      creatureManager = new AS.CreatureManager creature
      @_autoBlendSet = false

      creatureManager.SetTimeScale @options.dataFPS

      for name, animationData of data.animation
        creatureManager.AddAnimation new AS.CreatureAnimation data, name

      creatureManager
    ,
      true

    @creatureRenderer = new ComputedField =>
      return unless creature = @creature()
      return unless creatureManager = @creatureManager()
      materials = @materials()

      creatureRenderer = new AS.CreatureRenderer creature, creatureManager, materials.main
      creatureRenderer.renderMesh.castShadow = @options.castShadow
      creatureRenderer.renderMesh.receiveShadow = @options.receiveShadow
      creatureRenderer.renderMesh.customDepthMaterial = materials.depth

      # Add/replace the render mesh as a child.
      @remove @_currentRenderMesh
      @_currentRenderMesh = creatureRenderer.renderMesh
      @add @_currentRenderMesh

      creatureRenderer
    ,
      true

    # Reactively play animations.
    @currentAnimationName = new ReactiveField()
    @blendTime = new ReactiveField 0

    @autorun (computation) =>
      return unless creatureManager = @creatureManager()
      return unless creatureRenderer = @creatureRenderer()

      animationName = @currentAnimationName()
      animation = creatureManager.GetAnimation animationName if animationName

      if animation
        if @_autoBlendSet
          blendRate = 1 / @blendTime() / @options.playbackFPS
          creatureManager.AutoBlendTo animationName, blendRate

        else
          creatureManager.SetActiveAnimationName animationName
          creatureManager.SetAutoBlending true
          @_autoBlendSet = true

      else
        creatureManager.SetActiveAnimationName null
        return

      creatureManager.SetShouldLoop true
      creatureManager.SetIsPlaying true
      creatureManager.RunAtTime 0
      
      # Do the first update.
      creatureRenderer.UpdateData()

    @_accumulatedTime = 0

  destroy: ->
    super arguments...

    @creature.stop()
    @creatureManager.stop()
    @creatureRenderer.stop()

  animationNames: ->
    _.keys @data()?.animation

  update: (appTime) ->
    @_accumulatedTime += appTime.elapsedAppTime

    timeForUpdate = 1 / @options.playbackFPS

    while @_accumulatedTime > timeForUpdate
      @_accumulatedTime -= timeForUpdate

      @creatureManager()?.Update timeForUpdate
      @creatureRenderer()?.UpdateData()

  syncAnimationTo: (animatedMesh) ->
    runTime = animatedMesh.creatureManager().getRunTime()
    @creatureManager().setRunTime runTime
