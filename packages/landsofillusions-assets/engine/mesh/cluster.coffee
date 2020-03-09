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
    material.dispose() for name, material of @_materials if @_materials
    @_radianceState?.destroy()

  _generateGeometry: ->
    return unless geometryData = @data.geometry()

    # Clean any previous geometry.
    @_geometry?.dispose()

    console.log "Generating geometry", geometryData if LOI.Assets.debug

    @_geometry = new THREE.BufferGeometry
    @_geometry.setAttribute 'position', new THREE.BufferAttribute geometryData.vertices, 3
    @_geometry.setAttribute 'normal', new THREE.BufferAttribute geometryData.normals, 3
    @_geometry.setAttribute 'pixelCoordinates', new THREE.BufferAttribute geometryData.pixelCoordinates, 2 if geometryData.pixelCoordinates
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
    pbr = options.pbr?()

    materialOptions =
      wireframe: options.debug?()

    # Determine the color.
    clusterMaterial = @data.material()
    material = null

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
      # Normal color mode.
      if clusterMaterial.materialIndex?
        # Cluster has a material assigned. Add the material properties to material options.
        meshMaterial = meshData.materials.get(clusterMaterial.materialIndex).toPlainObject()

      else if clusterMaterial.paletteColor
        # Cluster has a direct palette color set. Add palette color's properties (ramp, shade) to material options.
        meshMaterial = clusterMaterial.paletteColor

      # PBR has its own material handling.
      if pbr
        shades = palette.ramps[meshMaterial.ramp]?.shades if meshMaterial.ramp?

        if materialOptions.wireframe
          if meshMaterial.extinctionCoefficient
            color = THREE.Color.fromObject meshMaterial.extinctionCoefficient

          else if meshMaterial.shade?
            color = THREE.Color.fromObject shades[meshMaterial.shade]

          else
            color = new THREE.Color 0xffffff

          material = new THREE.MeshBasicMaterial _.extend materialOptions, {color}

        else
          # Add extra data to options.
          sizeInPicturePixels = @data.sizeInPicturePixels() or {width: 1, height: 1}

          _.extend materialOptions,
            smoothShading: options.smoothShading?()
            clusterSize: new THREE.Vector2 sizeInPicturePixels.width, sizeInPicturePixels.height
            radianceStateField: @radianceState

          # Create material properties.
          _.extend materialOptions,
            refractiveIndex: new THREE.Vector3 1, 1, 1
            extinctionCoefficient: new THREE.Vector3
            emission: new THREE.Vector3

          if n = meshMaterial.refractiveIndex
            materialOptions.refractiveIndex.set n.r, n.g, n.b

          if k = meshMaterial.extinctionCoefficient
            materialOptions.extinctionCoefficient.set k.r, k.g, k.b

          if not (n or k) and shades and meshMaterial.shade?
            # Create an ad-hoc PBR material.
            materialOptions.refractiveIndex.set 1.5, 1.5, 1.5

            color = shades[meshMaterial.shade]
            materialOptions.extinctionCoefficient.set 1 - color.r, 1 - color.g, 1 - color.b

          if e = meshMaterial.emission
            materialOptions.emission.set e.r, e.g, e.b

          material = new LOI.Engine.Materials.PBRMaterial materialOptions

      # See if we have correct properties for a ramp material.
      else if meshMaterial.ramp? and palette.ramps[meshMaterial.ramp]
        shades = palette.ramps[meshMaterial.ramp]?.shades

        if materialOptions.wireframe
          material = new THREE.MeshBasicMaterial _.extend materialOptions,
            color: THREE.Color.fromObject shades[meshMaterial.shade]

        else
          # Note: We can't set extra properties on material options sooner since other materials don't support them.
          _.extend materialOptions, meshMaterial,
            palette: palette
            smoothShading: options.smoothShading?()

          materialId = materialOptions.type or LOI.Engine.Materials.RampMaterial.id()
          material = LOI.Engine.Materials.getMaterial materialId, materialOptions

          depthMaterial = LOI.Engine.Materials.getMaterial LOI.Engine.Materials.DepthMaterial.id(),
            texture: meshMaterial?.texture
            translucency: meshMaterial?.translucency

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

    mesh.castShadow = true
    mesh.receiveShadow = true
    mesh.layers.set 2 if @layer.object.mesh.options.debug?()

    mesh

  _generateRadianceState: ->
    # Clean any previous radiance state.
    @_radianceState?.destroy()

    if size = @data.sizeInPicturePixels()
      @_radianceState = new LOI.Engine.RadianceState
        size: size
        cluster: @data

    else
      @_radianceState = null

    @_radianceState
