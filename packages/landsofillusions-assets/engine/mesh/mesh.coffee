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

    @_renderMeshes = []
    @renderMeshes = new ReactiveField null

    @autorun (computation) =>
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

      @_renderMeshes = []
      
      for material, index in mainMaterials
        clusterList = clusterLists[index]
        materials = clusterList[0].materials()
        clusterGeometries = (cluster.geometry() for cluster in clusterList)

        geometry = THREE.BufferGeometryUtils.mergeBufferGeometries clusterGeometries

        mainMesh = new THREE.Mesh geometry, materials.main
        mainMesh.layers.set LOI.Engine.RenderLayers.FinalRender
  
        indirectMesh = new THREE.Mesh geometry, materials.indirect
        indirectMesh.layers.set LOI.Engine.RenderLayers.Indirect
  
        for mesh in [mainMesh, indirectMesh]
          mesh.customDepthMaterial = materials.depth
  
          mesh.castShadow = true
          mesh.receiveShadow = true
  
        @_renderMeshes.push mainMesh, indirectMesh
  
      @renderMeshes @_renderMeshes

    # Update mesh children.
    @autorun (computation) =>
      # Clean up previous children.
      @remove @children[0] while @children.length

      # Add individual objects (used for debugging).
      if objects = @objects()
        @add object for object in objects

      # Add merged meshes.
      if renderMeshes = @renderMeshes()
        @add mesh for mesh in renderMeshes

      @options.sceneManager.addedSceneObjects()

  destroy: ->
    super arguments...

    object.destroy() for object in @objects()
    mesh.geometry.dispose() for mesh in @_renderMeshes
