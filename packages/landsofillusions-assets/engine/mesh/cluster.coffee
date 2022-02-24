AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions

class LOI.Assets.Engine.Mesh.Object.Layer.Cluster extends AS.RenderObject
  constructor: (@layer, @data) ->
    super arguments...

    @geometry = new ComputedField => @_generateGeometry()
    @materials = new ComputedField => @_generateMaterials()
    @meshes = new ComputedField => @_generateMeshes()
    @points = new ComputedField => @_generatePoints()

    @ready = new ComputedField =>
      _.every [
        @geometry()
        @materials()
        @meshes()
      ]

    @boundingBox = new ComputedField =>
      @geometry().boundingBox

    # Update scene.
    @autorun (computation) =>
      # Clean up previous children.
      @remove @children[0] while @children.length

      options = @layer.object.mesh.options

      # Add the new mesh.
      if meshes = @meshes()
        @add meshes.selection
        @add meshes.visualizeNormals

        # If we have a selected cluster, don't draw others.
        currentCluster = options.currentCluster?()
        @add meshes.wireframe if not currentCluster or currentCluster is @data

      if points = @points()
        @add points

      options.sceneManager.addedSceneObjects()

  destroy: ->
    super arguments...

    @_geometry?.dispose()
    material?.dispose() for name, material of @_materials if @_materials

  _generateGeometry: ->
    return unless geometryData = @data.geometry()

    # Get the index in the material properties texture.
    meshData = @data.layer.object.mesh
    materialPropertiesIndex = meshData.materialProperties.getIndex @data.material()
    return unless materialPropertiesIndex?

    # Create the data for the material properties index attribute. We need to stretch possible values to the maximum
    # typed array value, since we'll use a normalized buffer that will map to float values between 0.0 and 1.0.
    materialPropertiesIndices = new Uint8Array geometryData.vertices.length / 3
    maxUint8Value = 255
    stretchFactor = maxUint8Value / (LOI.Engine.Textures.MaterialProperties.maxItems - 1)
    materialPropertiesIndices.fill materialPropertiesIndex * stretchFactor
    
    # Get the index in the layer properties texture.
    lightmapAreaPropertiesIndex = meshData.lightmapAreaProperties.getIndex @data
    return unless lightmapAreaPropertiesIndex?
    
    # Create the data for the layer properties index attribute.
    lightmapAreaPropertiesIndices = new Uint8Array geometryData.vertices.length / 3
    stretchFactor = maxUint8Value / (LOI.Engine.Textures.LightmapAreaProperties.maxItems - 1)
    lightmapAreaPropertiesIndices.fill lightmapAreaPropertiesIndex * stretchFactor

    # Clean any previous geometry.
    @_geometry?.dispose()

    console.log "Generating geometry", geometryData if LOI.Assets.debug

    @_geometry = new THREE.BufferGeometry
    @_geometry.setAttribute 'position', new THREE.BufferAttribute geometryData.vertices, 3
    @_geometry.setAttribute 'normal', new THREE.BufferAttribute geometryData.normals, 3
    @_geometry.setAttribute 'materialPropertiesIndex', new THREE.BufferAttribute materialPropertiesIndices, 1, true
    @_geometry.setAttribute 'lightmapAreaPropertiesIndex', new THREE.BufferAttribute lightmapAreaPropertiesIndices, 1, true
    @_geometry.setAttribute 'lightmapCoordinates', new THREE.BufferAttribute geometryData.pixelCoordinates, 2 if geometryData.pixelCoordinates
    @_geometry.setIndex new THREE.BufferAttribute geometryData.indices, 1
    @_geometry.computeBoundingBox()

    @_geometry

  _generateMaterials: ->
    meshData = @data.layer.object.mesh
    return unless palette = meshData.customPalette or LOI.Assets.Palette.documents.findOne meshData.palette._id

    # Clean any previous materials.
    material?.dispose() for name, material of @_materials if @_materials

    console.log "Generating materials", meshData if LOI.Assets.debug

    options = @layer.object.mesh.options
    compareToPhysicalMaterial = options.compareToPhysicalMaterial?()
    debug = options.debug?()

    # Create the main and depth materials.
    clusterMaterial = @data.material()
    material = null

    if clusterMaterial.materialIndex?
      # Cluster has a material assigned. Add the material properties to material options.
      meshMaterial = meshData.materials.get(clusterMaterial.materialIndex).toPlainObject()

    else if clusterMaterial.paletteColor
      # Cluster has a direct palette color set.
      meshMaterial = clusterMaterial.paletteColor
  
    materialOptions =
      mesh: meshData

    # If the meshMaterial has a texture, that's something we have to get a separate material for.
    materialOptions.texture = meshMaterial.texture if meshMaterial.texture

    # Translucent materials need to be separate from opaque ones to render second.
    materialOptions.translucency = meshMaterial.translucency if meshMaterial.translucency

    material = LOI.Engine.Materials.getMaterial LOI.Engine.Materials.UniversalMaterial.id(), materialOptions
    depthMaterial = LOI.Engine.Materials.getMaterial LOI.Engine.Materials.DepthMaterial.id(), materialOptions
    
    indirectMaterialOptions = _.extend
      indirectLayer: true
    ,
      materialOptions
  
    indirectMaterial = LOI.Engine.Materials.getMaterial LOI.Engine.Materials.UniversalMaterial.id(), indirectMaterialOptions
  
    if compareToPhysicalMaterial
      # We want to use three.js' Physical Material
      parameters = LOI.Assets.Mesh.Material.createPhysicalMaterialParameters meshMaterial, palette
      material = new THREE.MeshPhysicalMaterial parameters
    
    # Visualized normals mode.
    if clusterMaterial.normal
      normal = new THREE.Vector3 clusterMaterial.normal.x, clusterMaterial.normal.y, clusterMaterial.normal.z
      backward = new THREE.Vector3 0, 0, 1

      horizontalAngle = Math.atan2(normal.y, normal.x) + Math.PI
      verticalAngle = normal.angleTo backward

      hue = horizontalAngle / (2 * Math.PI)
      saturation = verticalAngle / (Math.PI / 2)

      if Math.abs(verticalAngle) > Math.PI / 2
        lightness = 1 - Math.abs(verticalAngle) / Math.PI

      else
        lightness = 0.5

      directColor = new THREE.Color().setHSL hue, saturation, lightness

    else
      directColor = r: 0, g: 0, b: 0

    visualizeNormalsMaterial = new THREE.MeshBasicMaterial
      color: THREE.Color.fromObject directColor
      wireframe: debug or false

    shades = palette.ramps[meshMaterial.ramp]?.shades

    wireframeMaterial = new THREE.MeshBasicMaterial
      wireframe: true
      color: THREE.Color.fromObject shades[meshMaterial.shade]

    @_materials =
      main: material
      indirect: indirectMaterial
      depth: depthMaterial
      visualizeNormals: visualizeNormalsMaterial
      wireframe: wireframeMaterial

    @_materials

  _generateMeshes: ->
    return unless geometry = @geometry()
    return unless materials = @materials()

    console.log "Generating meshes", geometry, materials if LOI.Assets.debug

    selectionMesh = new THREE.Mesh geometry, materials.main
    selectionMesh.layers.set LOI.Assets.MeshEditor.RenderLayers.Selection

    visualizeNormalsMesh = new THREE.Mesh geometry, materials.visualizeNormals
    visualizeNormalsMesh.layers.set LOI.Assets.MeshEditor.RenderLayers.VisualizeNormals

    wireframeMesh = new THREE.Mesh geometry, materials.wireframe
    wireframeMesh.layers.set LOI.Assets.MeshEditor.RenderLayers.Wireframe

    selection: selectionMesh
    visualizeNormals: visualizeNormalsMesh
    wireframe: wireframeMesh

  _generatePoints: ->
    # Only generate points during debug to minimize creation of geometry when not needed.
    return unless @layer.object.mesh.options.debug?()

    solverCluster = @data.layer.object.solver.clusters[@data.id]
    points = solverCluster.getPoints()
    points.layers.set LOI.Assets.MeshEditor.RenderLayers.Wireframe
    points
