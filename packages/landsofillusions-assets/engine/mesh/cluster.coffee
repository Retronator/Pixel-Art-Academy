AS = Artificial.Spectrum
LOI = LandsOfIllusions

class LOI.Assets.Engine.Mesh.Object.Layer.Cluster extends AS.RenderObject
  constructor: (@layer, @data) ->
    super arguments...

    @geometry = new ComputedField => @_generateGeometry()
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

  _generateGeometry: ->
    return unless geometryData = @data.geometry()

    geometry = new THREE.BufferGeometry
    geometry.addAttribute 'position', new THREE.BufferAttribute geometryData.vertices, 3
    geometry.addAttribute 'normal', new THREE.BufferAttribute geometryData.normals, 3
    geometry.setIndex new THREE.BufferAttribute geometryData.indices, 1
    geometry.computeBoundingBox()

    geometry

  _generateMaterials: ->
    meshData = @data.layer.object.mesh
    return unless palette = meshData.customPalette or LOI.Assets.Palette.documents.findOne meshData.palette._id

    options = @layer.object.mesh.options
    visualizeNormals = options.visualizeNormals?()

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

      # See if we have correct properties for a ramp material.
      if meshMaterial.ramp? and palette.ramps[meshMaterial.ramp]
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

    main: material
    depth: depthMaterial
    shadowColor: shadowColorMaterial
    preprocessing: preprocessingMaterial

  _generateMesh: ->
    return unless geometry = @geometry()
    return unless materials = @materials()

    mesh = new THREE.Mesh geometry, materials.main

    mesh.mainMaterial = materials.main
    mesh.shadowColorMaterial = materials.shadowColor
    mesh.customDepthMaterial = materials.depth
    mesh.preprocessingMaterial = materials.preprocessing

    mesh.castShadow = true
    mesh.receiveShadow = true
    mesh.layers.set 2 if @layer.object.mesh.options.debug?()

    mesh
