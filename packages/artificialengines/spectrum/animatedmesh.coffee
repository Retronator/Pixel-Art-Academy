AE = Artificial.Everywhere
AS = Artificial.Spectrum

class AS.AnimatedMesh extends AS.RenderObject
  constructor: (@options) ->
    super arguments...

    @data = new ReactiveField @options.data
    @boneCorrections = new ReactiveField @options.boneCorrections
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
      alphaTest: 1

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

      boneCorrections = @boneCorrections()
      return if @options.waitForBoneCorrections and not boneCorrections

      if boneCorrections
        data = _.clone data
        data.skeleton = _.clone data.skeleton

        for boneName, correction of boneCorrections
          data.skeleton[boneName] = _.cloneDeep data.skeleton[boneName]
          bone = data.skeleton[boneName]
          matrix4 = new THREE.Matrix4
          matrix4.elements = bone.restParentMat

          matrix3 = new THREE.Matrix3().setFromMatrix4 matrix4
          matrix3 = new THREE.Matrix3().getInverse matrix3

          translation = new THREE.Vector2 correction.x, -correction.y
          translation.applyMatrix3(matrix3).multiplyScalar -1

          bone.localRestStartPt[0] += translation.x
          bone.localRestStartPt[1] += translation.y
          bone.localRestEndPt[0] += translation.x
          bone.localRestEndPt[1] += translation.y

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
    @randomStart = new ReactiveField false

    @autorun (computation) =>
      return unless creatureManager = @creatureManager()
      return unless creatureRenderer = @creatureRenderer()

      return unless animationName = @currentAnimationName()
      return unless animation = creatureManager.GetAnimation animationName if animationName

      if @_autoBlendSet
        blendRate = 1 / @blendTime() / @options.playbackFPS
        creatureManager.AutoBlendTo animationName, blendRate

      else
        creatureManager.SetActiveAnimationName animationName
        creatureManager.SetAutoBlending true
        @_autoBlendSet = true

      creatureManager.SetShouldLoop true
      creatureManager.SetIsPlaying true
      
      if @randomStart
        length = animation.endTime
        time = Math.random() * length
        
      else
        time = 0
        
      creatureManager.RunAtTime time
      
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

  update: (appTime, updateData = true) ->
    @_accumulatedTime += appTime.elapsedAppTime

    timeForUpdate = 1 / @options.playbackFPS

    return unless @_accumulatedTime > timeForUpdate

    @creatureManager()?.Update @_accumulatedTime
    @creatureRenderer()?.UpdateData() if updateData

    @_accumulatedTime = 0

  syncAnimationTo: (otherAnimatedMesh) ->
    return unless otherCreatureManager = otherAnimatedMesh.creatureManager()
    animationName = otherCreatureManager.GetActiveAnimationName()
    runTime = otherCreatureManager.getRunTime()

    return unless creatureManager = @creatureManager()
    return unless creatureManager.GetAnimation animationName

    creatureManager.SetBlendingAnimations animationName, animationName
    creatureManager.RunAtTime runTime

    @creatureRenderer().UpdateData()
