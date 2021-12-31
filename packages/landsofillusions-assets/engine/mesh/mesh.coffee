AS = Artificial.Spectrum
LOI = LandsOfIllusions

class LOI.Assets.Engine.Mesh extends AS.RenderObject
  constructor: (@options) ->
    super arguments...

    @objects = new ReactiveField null

    @ready = new ComputedField =>
      return unless objects = @objects()

      for object in objects
        return unless object.ready()

      true

    # Generate objects.
    @autorun (computation) =>
      return unless meshData = @options.meshData()
      return unless objectsData = meshData.objects.getAllWithoutUpdates()
      
      engineObjects = for objectData in objectsData
        new @constructor.Object @, objectData

      @objects engineObjects

    # Create illumination state.
    @illuminationState = new ReactiveField null
    @autorun (computation) => @_generateIlluminationState()

    # Update light map properties texture.
    @autorun (computation) =>
      return unless meshData = @options.meshData()
      return unless illuminationState = @illuminationState()

      meshData.lightmapAreaProperties.updateTexture illuminationState

    @_renderMeshes = []
    @renderMeshes = new ReactiveField null

    @autorun (computation) =>
      return unless gi = @options.gi?()
      return unless objects = @objects()

      mainMaterials = []
      clusterLists = []

      for object in objects when object.data.visible()
        for layer in object.engineLayers() when layer.data.visible()
          for cluster in layer.clusters()
            return unless cluster.geometry()
            return unless mainMaterial = cluster.materials()?.main
            index = mainMaterials.indexOf mainMaterial

            # Add new material if necessary.
            if index is -1
              index = mainMaterials.length
              mainMaterials.push mainMaterial
              clusterLists.push []

            # Add cluster to the list of clusters for this material.
            clusterLists[index].push cluster

      # Clean any previous geometry.
      mesh.geometry.dispose() for mesh in @_renderMeshes

      @_renderMeshes = for material, index in mainMaterials
        clusterList = clusterLists[index]
        materials = clusterList[0].materials()
        clusterGeometries = (cluster.geometry() for cluster in clusterList)

        geometry = THREE.BufferGeometryUtils.mergeBufferGeometries clusterGeometries

        giMaterial = new LOI.Engine.Materials.GIMaterial
          illuminationStateField: @illuminationState
          mesh: @options.meshData()
          texture: materials.main.options?.texture

        material = if gi then giMaterial else materials.main

        mesh = new THREE.Mesh geometry, material

        mesh.mainMaterial = material
        mesh.shadowColorMaterial = materials.shadowColor
        mesh.customDepthMaterial = materials.depth
        mesh.preprocessingMaterial = materials.preprocessing
        mesh.giMaterial = giMaterial

        mesh.castShadow = true
        mesh.receiveShadow = true

        mesh

      @renderMeshes @_renderMeshes

    # Update mesh children.
    @autorun (computation) =>
      # Clean up previous children.
      @remove @children[0] while @children.length

      debug = @options.debug?()
      pbr = @options.pbr?()
      gi = @options.gi?()

      if debug or pbr or not gi
        # We always add individual objects, except in GI mode.
        objects = @objects()
        return unless objects?.length

        @add object for object in objects

      if gi
        # During GI we always need the merged mesh.
        renderMeshes = @renderMeshes()
        return unless renderMeshes?.length

        @add mesh for mesh in renderMeshes

      @options.sceneManager.addedSceneObjects()

  destroy: ->
    super arguments...

    object.destroy() for object in @objects()
    mesh.geometry.dispose() for mesh in @_renderMeshes

  _generateIlluminationState: ->
    return unless @options.gi?()
    return unless meshData = @options.meshData()

    # Clean any previous illumination state.
    @_illuminationState?.destroy()
    @_illuminationState = null

    # Make sure lightmap size isn't zero.
    return unless meshData.lightmapAreaProperties.lightmapSize().width > 0

    @_illuminationState = new LOI.Engine.IlluminationState meshData
    @illuminationState @_illuminationState
