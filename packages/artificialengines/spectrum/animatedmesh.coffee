AE = Artificial.Everywhere
AS = Artificial.Spectrum

class AS.AnimatedMesh extends AS.RenderObject
  @_dataEntryCache = {}

  @getCachedDataEntryField: (dataUrl) ->
    # Return the singleton field if we already have it.
    return @_dataEntryCache[dataUrl] if @_dataEntryCache[dataUrl]

    # Create a new field.
    @_dataEntryCache[dataUrl] = new ReactiveField null

    # Start loading its content.
    $.getJSON dataUrl, (data) =>
      animations = {}
      
      for name, animationData of data.animation
        animations[name] = new AS.CreatureAnimation data, name

      @_dataEntryCache[dataUrl] {data, animations}

    # Return the new field.
    @_dataEntryCache[dataUrl]

  constructor: (@options) ->
    super arguments...

    # Load data if provided with its URLs.
    if @options.dataUrl
      @dataEntry = @constructor.getCachedDataEntryField @options.dataUrl

    else
      @dataEntry = new ReactiveField @options.data

    @boneCorrections = new ReactiveField @options.boneCorrections

    # Load texture if provided with its URLs.
    @texture = new ReactiveField @options.texture

    if @options.textureUrl
      textureLoader = new THREE.TextureLoader()
      textureLoader.crossOrigin = 'use-credentials'

      texture = textureLoader.load @options.textureUrl
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
      return unless dataEntry = @dataEntry()

      new AS.Creature dataEntry.data
    ,
      true

    @creatureManager = new ComputedField =>
      boneCorrections = @boneCorrections()
      return if @options.waitForBoneCorrections and not boneCorrections

      return unless creature = @creature()
      dataEntry = @dataEntry()

      creatureManager = new AS.CreatureManager creature
      @_autoBlendSet = false

      creatureManager.SetTimeScale @options.dataFPS

      for name, animation of dataEntry.animations
        creatureManager.AddAnimation animation

      if boneCorrections and _.keys(boneCorrections).length
        creatureManager.bones_override_callback = (bonesMap) =>
          for boneName, correction of boneCorrections
            unless bone = bonesMap[boneName]
              unless @_missingBoneWarned?[boneName]
                console.warn "Bone #{boneName} to be corrected does not exist in the skeleton."
                @_missingBoneWarned ?= {}
                @_missingBoneWarned[boneName] = true

              continue

            @_applyBoneCorrection bone, correction

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
      return unless animation = creatureManager.GetAnimation animationName

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

  _applyBoneCorrection: (bone, correction) ->
    bone.world_start_pt[0] += correction.x
    bone.world_start_pt[1] -= correction.y
    bone.world_end_pt[0] += correction.x
    bone.world_end_pt[1] -= correction.y

    for child in bone.children
      @_applyBoneCorrection child, correction

  animationNames: ->
    _.keys @dataEntry()?.animation

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
    runTime = otherCreatureManager.getActualRuntime()

    return unless creatureManager = @creatureManager()
    return unless creatureManager.GetAnimation animationName

    creatureManager.SetBlendingAnimations animationName, animationName
    creatureManager.RunAtTime runTime

    @creatureRenderer().UpdateData()
