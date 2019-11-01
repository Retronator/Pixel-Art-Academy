AE = Artificial.Everywhere
AS = Artificial.Spectrum

class AS.AnimatedMesh extends AS.RenderObject
  @_dataCache = {}

  @getCachedDataField: (dataUrl) ->
    # Return the singleton field if we already have it.
    return @_dataCache[dataUrl] if @_dataCache[dataUrl]

    # Create a new field.
    @_dataCache[dataUrl] = new ReactiveField null

    # Start loading its content.
    $.getJSON dataUrl, (data) =>
      @_dataCache[dataUrl] data

    # Return the new field.
    @_dataCache[dataUrl]

  constructor: (@options) ->
    super arguments...

    # Load data if provided with its URLs.
    if @options.dataUrl
      @data = @constructor.getCachedDataField @options.dataUrl

    else
      @data = new ReactiveField @options.data

    @boneCorrections = new ReactiveField @options.boneCorrections

    # Load texture if provided with its URLs.
    @texture = new ReactiveField @options.texture

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

    # Prepare animation data.
    @correctedData = new ComputedField =>
      return unless data = @data()

      boneCorrections = @boneCorrections()
      return if @options.waitForBoneCorrections and not boneCorrections

      if boneCorrections
        data = _.clone data
        data.animation = _.clone data.animation

        # See which bones will need offset.
        bonesThatNeedOffset = {}

        addBonesThatNeedOffset = (bone) =>
          return if bonesThatNeedOffset[bone.name]
          bonesThatNeedOffset[bone.name] = true

          for childId in bone.children
            childBone = _.find data.skeleton, (bone) => bone.id is childId
            addBonesThatNeedOffset childBone

        addBonesThatNeedOffset data.skeleton[boneName] for boneName of boneCorrections

        for animationName, animation of data.animation
          data.animation[animationName] = _.clone animation
          bones = _.clone animation.bones
          data.animation[animationName].bones = bones

          for frameNumber, frame of bones
            bones[frameNumber] = _.clone frame

            # Only clone bones that will be offset.
            for boneName of bonesThatNeedOffset
              bones[frameNumber][boneName] = _.clone frame[boneName]

        for boneName, correction of boneCorrections
          unless data.skeleton[boneName]
            console.warn "Bone #{boneName} to be corrected does not exist in the skeleton."
            continue

          for animationName, animation of data.animation
            for frameNumber, frame of animation.bones
              # Offset bone and all children. We do this in world space to avoid computation of proper correction in
              # bone space which would require calculating all hierarchy matrices per frame. For non-extreme animations
              # (that don't go too far away from the rest pose) this is good enough.
              offsetBone = (bone) =>
                frame[bone.name].start_pt = [frame[bone.name].start_pt[0] + correction.x, frame[bone.name].start_pt[1] + correction.y]
                frame[bone.name].end_pt = [frame[bone.name].end_pt[0] + correction.x, frame[bone.name].end_pt[1] + correction.y]

                for childId in bone.children
                  childBone = _.find data.skeleton, (bone) => bone.id is childId
                  offsetBone childBone

              offsetBone data.skeleton[boneName]

      data

    # Create creature objects.
    @creature = new ComputedField =>
      return unless data = @correctedData()

      new AS.Creature data
    ,
      true

    @creatureManager = new ComputedField =>
      return unless creature = @creature()
      data = @correctedData()

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
    runTime = otherCreatureManager.getActualRuntime()

    return unless creatureManager = @creatureManager()
    return unless creatureManager.GetAnimation animationName

    creatureManager.SetBlendingAnimations animationName, animationName
    creatureManager.RunAtTime runTime

    @creatureRenderer().UpdateData()
