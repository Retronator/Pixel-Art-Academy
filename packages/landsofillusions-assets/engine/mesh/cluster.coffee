LOI = LandsOfIllusions

class LOI.Assets.Engine.Mesh.Object.Layer.Cluster extends THREE.Object3D
  constructor: (@layer, @clusterData) ->
    super arguments...

    @geometry = new ComputedField => @_generateGeometry()
    @material = new ComputedField => @_generateMaterial()
    @mesh = new ComputedField => @_generateMesh()
    
    # Update scene.
    Tracker.autorun (computation) =>
      # Clean up previous children.
      @remove @children[0] while @children.length

      # Add the new mesh.
      if mesh = @mesh()
        @add mesh

      options = @layer.object.mesh.options

      if options.debug?()
        # Add points.
        solverCluster = @clusterData.layer.object.solver.clusters[@clusterData.id]
        points = solverCluster.getPoints()
        points.layers.set 2
        @add points

      options.sceneManager.scene.updated()

  _generateGeometry: ->
    return unless geometryData = @clusterData.geometry()

    geometry = new THREE.BufferGeometry
    geometry.addAttribute 'position', new THREE.BufferAttribute geometryData.vertices, 3
    geometry.addAttribute 'normal', new THREE.BufferAttribute geometryData.normals, 3
    geometry.setIndex new THREE.BufferAttribute geometryData.indices, 1

    geometry

  _generateMaterial: ->
    meshData = @clusterData.layer.object.mesh
    return unless palette = meshData.customPalette or LOI.Assets.Palette.documents.findOne meshData.palette._id

    options = @layer.object.mesh.options
    visualizeNormals = options.visualizeNormals?()

    materialOptions =
      wireframe: options.debug?() or false

    # Determine the color.
    materialData = @clusterData.material()
    material = null

    if visualizeNormals
      # Visualized normals mode.
      if materialData.normal
        normal = new THREE.Vector3 materialData.normal.x, materialData.normal.y, materialData.normal.z
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
      paletteColor = null

      # Normal color mode.
      if materialData.materialIndex?
        material = meshData.materials.get materialData.materialIndex

        paletteColor = _.clone material.toPlainObject()

        # Override material data if we have it present.
        if materialData = materialsData?[material.name]
          for key, value of materialData
            paletteColor[key] = value if value?

      else if materialData.paletteColor
        paletteColor = materialData.paletteColor

      if paletteColor and palette.ramps[paletteColor.ramp]
        shades = palette.ramps[paletteColor.ramp]?.shades
        shadeIndex = THREE.Math.clamp paletteColor.shade, 0, shades.length - 1

        if materialOptions.wireframe
          material = new THREE.MeshBasicMaterial _.extend materialOptions,
            color: THREE.Color.fromObject shades[paletteColor.shade]

        else
          material = new LOI.Engine.Materials.RampMaterial _.extend materialOptions, {shades, shadeIndex}

      else if materialData.directColor
        material = new THREE.MeshLambertMaterial _.extend materialOptions,
          color: THREE.Color.fromObject materialData.directColor

      else
        material = new THREE.MeshLambertMaterial _.extend materialOptions,
          color: new THREE.Color 0xffffff

    material

  _generateMesh: ->
    return unless geometry = @geometry()
    return unless material = @material()

    mesh = new THREE.Mesh geometry, material

    mesh.castShadow = true
    mesh.receiveShadow = true
    mesh.material.shadowSide = THREE.BackSide
    mesh.layers.set 2 if @layer.object.mesh.options.debug?()

    mesh
