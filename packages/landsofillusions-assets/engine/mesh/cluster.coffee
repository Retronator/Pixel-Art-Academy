AS = Artificial.Spectrum
LOI = LandsOfIllusions

class LOI.Assets.Engine.Mesh.Object.Layer.Cluster extends AS.RenderObject
  constructor: (@layer, @data) ->
    super arguments...

    @geometry = new ComputedField => @_generateGeometry()
    @radianceState = new ComputedField => @_generateRadianceState()
    @materials = new ComputedField => @_generateMaterials()
    @mesh = new ComputedField => @_generateMesh()

    @ready = new ComputedField =>
      _.every [
        @geometry()
        @materials()
        @mesh()
      ]

    @boundingBox = new ComputedField =>
      @geometry().boundingBox

    # Update scene.
    @autorun (computation) =>
      # Clean up previous children.
      @remove @children[0] while @children.length

      # Add the new mesh.
      if mesh = @mesh()
        @add mesh

      options = @layer.object.mesh.options

      if options.debug?()
        # Add points.
        solverCluster = @data.layer.object.solver.clusters[@data.id]
        points = solverCluster.getPoints()
        points.layers.set 2
        @add points

      options.sceneManager.addedSceneObjects()

  destroy: ->
    super arguments...

    @_geometry?.dispose()
    material?.dispose() for name, material of @_materials if @_materials
    @_radianceState?.destroy()

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
    visualizeNormals = options.visualizeNormals?()

    materialOptions =
      wireframe: options.debug?() or false

    # Determine the color.
    clusterMaterial = @data.material()
    material = null

    # Normal color mode.
    if clusterMaterial.materialIndex?
      # Cluster has a material assigned. Add the material properties to material options.
      meshMaterial = meshData.materials.get(clusterMaterial.materialIndex).toPlainObject()

    else if clusterMaterial.paletteColor
      # Cluster has a direct palette color set.
      meshMaterial = clusterMaterial.paletteColor

    if visualizeNormals
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

      material = new THREE.MeshBasicMaterial _.extend materialOptions,
        color: THREE.Color.fromObject directColor

    else
      # See if we have correct properties for a ramp material.
      if meshMaterial.ramp? and palette.ramps[meshMaterial.ramp]
        shades = palette.ramps[meshMaterial.ramp]?.shades

        if materialOptions.wireframe
          material = new THREE.MeshBasicMaterial _.extend materialOptions,
            color: THREE.Color.fromObject shades[meshMaterial.shade]

        else
          # Note: We can't set extra properties on material options sooner since other materials don't support them.
          _.extend materialOptions,
            mesh: meshData
            palette: palette
            colorQuantization: options.colorQuantization?()

          # If the meshMaterial has a texture, that's something we have to get a separate material for.
          materialOptions.texture = meshMaterial.texture if meshMaterial.texture

          # Translucent materials need to be separate from opaque ones to render second.
          materialOptions.translucency = meshMaterial.translucency if meshMaterial.translucency

          material = LOI.Engine.Materials.getMaterial LOI.Engine.Materials.UniversalMaterial.id(), materialOptions
          depthMaterial = LOI.Engine.Materials.getMaterial LOI.Engine.Materials.DepthMaterial.id(), materialOptions
          shadowColorMaterial = LOI.Engine.Materials.getMaterial LOI.Engine.Materials.ShadowColorMaterial.id(), materialOptions
          preprocessingMaterial = LOI.Engine.Materials.getMaterial LOI.Engine.Materials.PreprocessingMaterial.id(), materialOptions

      else if clusterMaterial.directColor
        material = new THREE.MeshLambertMaterial _.extend materialOptions,
          color: THREE.Color.fromObject clusterMaterial.directColor

      else
        material = new THREE.MeshLambertMaterial _.extend materialOptions,
          color: new THREE.Color 0xffffff

    @_materials =
      main: material
      depth: depthMaterial
      shadowColor: shadowColorMaterial
      preprocessing: preprocessingMaterial

    @_materials

  _generateMesh: ->
    return unless geometry = @geometry()
    return unless materials = @materials()

    console.log "Generating mesh", geometry, materials if LOI.Assets.debug

    mesh = new THREE.Mesh geometry, materials.main

    mesh.mainMaterial = materials.main
    mesh.shadowColorMaterial = materials.shadowColor
    mesh.customDepthMaterial = materials.depth
    mesh.preprocessingMaterial = materials.preprocessing
    mesh.pbrMaterial = materials.pbr

    mesh.castShadow = true
    mesh.receiveShadow = true

    debug = @layer.object.mesh.options.debug?()
    mesh.layers.set 3 if debug

    # Do not draw unselected clusters in debug mode. Note that we still want
    # to have them in the scene so they can be rendered in radiance probes.
    currentCluster = @layer.object.mesh.options.currentCluster?()

    mesh.visible = false if debug and currentCluster and currentCluster isnt @data

    mesh

  _generateRadianceState: ->
    options = @layer.object.mesh.options
    return unless options.pbr?()

    # Clean any previous radiance state.
    @_radianceState?.destroy()
    @_radianceState = null

    # Make sure bounds and picture cluster exist.
    return unless @data.boundsInPicture()
    return unless @data.layer.getPictureCluster @data.id

    meshData = @data.layer.object.mesh

    # Determine the color.
    return unless palette = meshData.customPalette or LOI.Assets.Palette.documents.findOne meshData.palette._id
    clusterMaterial = @data.material()

    # Normal color mode.
    if clusterMaterial.materialIndex?
      # Cluster has a material assigned. Add the material properties to material options.
      meshMaterial = meshData.materials.get(clusterMaterial.materialIndex).toPlainObject()

    else if clusterMaterial.paletteColor
      # Cluster has a direct palette color set.
      meshMaterial = clusterMaterial.paletteColor

    shades = palette.ramps[meshMaterial.ramp]?.shades if meshMaterial.ramp?

    # Generate material properties.
    materialProperties =
      refractiveIndex: new THREE.Vector3 1, 1, 1
      extinctionCoefficient: new THREE.Vector3
      emission: new THREE.Vector3
      albedo: new THREE.Vector3 -1, -1, -1

    if n = meshMaterial.refractiveIndex
      materialProperties.refractiveIndex.set n.r, n.g, n.b

    if k = meshMaterial.extinctionCoefficient
      materialProperties.extinctionCoefficient.set k.r, k.g, k.b

    if not (n or k) and shades and meshMaterial.shade?
      # Create an albedo-based material.
      materialProperties.refractiveIndex.set 1.5, 1.5, 1.5

      color = shades[meshMaterial.shade]
      linearColor = AS.Color.SRGB.getNormalizedRGBForGammaRGB color
      materialProperties.albedo.set linearColor.r, linearColor.g, linearColor.b

    if e = meshMaterial.emission
      materialProperties.emission.set e.r, e.g, e.b

    @_radianceState = new LOI.Engine.RadianceState @data, materialProperties

    @_radianceState
