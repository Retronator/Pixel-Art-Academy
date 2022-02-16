AE = Artificial.Everywhere
AM = Artificial.Mummification
LOI = LandsOfIllusions

# A 3D model asset.
class LOI.Assets.Mesh extends LOI.Assets.VisualAsset
  @id: -> 'LandsOfIllusions.Assets.Mesh'
  # planeGrid:
  #   size: the number of units the grid covers
  #   spacing: the spacing in units between major lines
  #   subdivisions: the number of minor lines between the major lines
  # cameraAngles: array of scene viewpoints
  #   name: text identifier
  #   picturePlaneDistance: the distance in world units the picture plane is from the camera, or null for ortographic
  #   picturePlaneOffset: offset of the center of the picture plane in pixels
  #     x, y
  #   pixelSize: the size of a camera pixel in world units
  #   position: location of the camera in world space
  #     x, y, z
  #   target: location of where the camera is pointing
  #     x, y, z
  #   up: up direction of the camera
  #     x, y, z
  #   customMatrix: array of 9 matrix elements in row-major order
  # objects: array of scene objects
  #   name: name of the object
  #   visible: boolean if the object is rendered
  #   solver:
  #     type: name of the solver used to construct the mesh from the pictures, with possible values:
  #       polyhedron (default, object with only flat surfaces)
  #       organic (object with a continuously curved surface)
  #       plane (all clusters are positioned in one plane)
  #       rope (deformable lines)
  #       cloth (deformable surface)
  #     polyhedron: additional options for the polyhedron solver
  #       cleanEdgePixels: boolean whether to add/remove edge pixels to better fit possible geometry
  #   lastClusterId: the last unique integer used to create a cluster
  #   layers: array of
  #     name: name of the layer
  #     visible: boolean if this layer should be drawn
  #     order: floating point order of the layer
  #     pictures: array of images that describe the object, indexed by cameraAngle index
  #       bounds: dimensions of the bitmap
  #         x, y: top-left corner relative to the camera origin (z-axis)
  #         width, height: size of the bitmap
  #       maps: object of texture maps that hold information for this picture
  #         {type}: what information is contained in this map, with possible values:
  #             flags (1 byte per pixel: which of the maps are valid at each pixel)
  #             clusterId (2 bytes per pixel: which cluster this pixel belongs to)
  #             materialIndex (flag value 1, 1 byte per pixel: index)
  #             paletteColor (flag value 2, 2 bytes per pixel: ramp, shade)
  #             directColor (flag value 4, 3 bytes per pixel: r, g, b)
  #             alpha (flag value 8, 1 byte per pixel: a)
  #             normal (flag value 16, 3 bytes per pixel: x, y, z as signed bytes (-1 to 1 float mapped to -127 to 127))
  #           data: array buffer holding the pixels, not sent to the server
  #           compressedData: binary object with compressed version of data, sent to the server
  #       clusters: map of auto-generated clusters detected in the picture
  #         {id}: unique integer identifying this cluster in the layer
  #           sourceCoordinates: absolute coordinates in the picture where this cluster's map information is taken from
  #             x, y
  #     clusters: map of auto-generated clusters in world space
  #       {id}: unique integer identifying this cluster in the layer
  #         properties: user-defined properties set on the cluster
  #           name: unique name by which the cluster can be referenced in code
  #           navigable: boolean if the cluster is navigable for pathfinding purposes
  #           coplanarPoint: forces the cluster to use this point for its plane
  #             x, y, z
  #           attachment: how the cluster relates to other objects in the scene, with possible values:
  #             null (does not relate to other objects)
  #             contact (gets positioned against another object's cluster with the opposite normal
  #             fixed (same as contact, but also creates a physical bond to the other object)
  #           extrusion: how much to extrude the cluster by (generates extra geometry)
  #         plane: the world plane for flat clusters
  #           point: a point in the plane
  #             x, y, z
  #           normal: the normal of the plane
  #             x, y, z
  #         material: subset of properties of the picture cluster (relevant map values at source coordinates)
  #           materialIndex, paletteColor, directColor, alpha, normal
  #         geometry:
  #           vertices: Float32Array with vertices of the cluster, not sent to the server
  #           compressedVertices: binary object with compressed version of vertices, sent to the server
  #           normals: Float32Array with normals of the cluster, not sent to the server
  #           compressedNormals: binary object with compressed version of normals, sent to the server
  #           indices: UInt32Array with indices of the cluster, not sent to the server
  #           compressedIndices: binary object with compressed version of indices, sent to the server
  #           pixelCoordinates: UInt32Array with pixel coordinates of the cluster, not sent to the server
  #           compressedPixelCoordinates: binary object with compressed version of pixel coordinates, sent to the server
  #           layerPixelCoordinates: UInt32Array with pixel coordinates of the cluster relative to layer origin, not sent to the server
  #           compressedLayerPixelCoordinates: binary object with compressed version of layer pixel coordinates, sent to the server
  #         boundsInPicture: the position and size of the cluster in picture pixels
  #           x, y, width, height
  # materials: array of shaders used to draw objects
  #   name: what the materials represents
  #   type: ID of the shader
  #   ramp: index of the ramp within the palette
  #   shade: index of the shade in the ramp
  #   dither: amount of dither used from 0 to 1
  #   reflection:
  #     intensity: amount of perfectly reflected light
  #     shininess: the Phong exponent controlling how smooth the surface is (high is more smooth, producing sharp, shiny reflections)
  #     smoothFactor: option to smooth the normals of the texture itself
  #   translucency:
  #     amount: amount from 0 to 1, how much the rest of the scene should be seen through this material
  #     dither: amount from 0 to 1, how much of transparency dither to apply to this material
  #     tint: boolean whether the ramp of this material should be applied to the objects behind it
  #     blending:
  #       preset: one of THREE.js blending mode keys
  #       equation: one of THREE.js blending equation keys
  #       sourceFactor: one of THREE.js source factor keys
  #       destinationFactor: one of THREE.js destination factor keys
  #     shadow:
  #       dither: amount from 0 to 1, how much the shadow is dithered (default matches the translucency dither)
  #       tint: boolean whether the ramp of this material should be applied to the objects in the shadow of it
  #   materialClass: ID of the built-in material class this material represents, null for custom material
  #   refractiveIndex: spectral distribution of the refractive index (derived from the material class, or custom — custom only has the r component set)
  #     r, g, b
  #   temperature: temperature in Kelvin the material is at, or null for custom emission
  #   emission: spectral distribution of the maximum emission of the material (derived from temperature, or custom)
  #     r, g, b
  #   reflectance: reflected light of the material at normal incidence (precomputed from the material class' refractive index)
  #     r, g, b
  #   surfaceRoughness: how smooth or rough the surface is from 0 to 1
  #   subsurfaceHeterogeneity: how much the refractive index varies under the surface from 0 to 1
  #   conductivity: how much the material conducts electricity from 0 to 1 (derived from the material class, or custom)
  #   texture:
  #     spriteId: ID of the sprite to be used as the texture
  #     spriteName: Name of the sprite or mip to be used as the texture
  #     mappingMatrix: array of 6 matrix elements for transforming vertex positions to texture coordinates
  #     mappingOffset: 2D vector how much to offset texture coordinates by
  #       x, y
  #     anisotropicFiltering: boolean whether to use anisotropic filtering
  #     minificationFilter: texture filtering used for reducing the texture
  #     magnificationFilter: texture filtering used for enlarging the texture
  #     mipmapFilter: texture filtering used for sampling mipmaps
  #     mipmapBias: floating point number used to adjust mipmap selection
  # landmarks: array of named locations, as defined for visual asset
  #   ...
  #   object: integer index of the object this landmark is on
  #   layer: integer index of the object layer this landmarks is on
  #   cameraAngle: integer index of the camera layer this landmark's (x,y) location is defined from
  @Meta
    name: @id()

  # Store the class name of the visual asset by which we can reach the class by querying LOI.Assets. We can't simply
  # use the name parameter, because in production the name field has a minimized value.
  @className: 'Mesh'

  # Methods

  @load: @method 'load'
  @save: @method 'save'

  @landmarkPattern =
    name: Match.OptionalOrNull String
    object: Match.Optional Number
    layer: Match.Optional Number
    cameraAngle: Match.Optional Number
    x: Match.Optional Number
    y: Match.Optional Number

  @TextureFilters:
    Nearest: 'Nearest'
    Linear: 'Linear'

  initialize: (initializeRuntimeData, propertiesChangedDependency) ->
    # Make sure we don't initialize it multiple times.
    if @_initialized
      console.warn "Multiple calls to initialize of mesh", @
      return

    # Track whether we need to save the mesh.
    @dirty = new ReactiveField false
    @_updatedDependency = new Tracker.Dependency

    # Initialize array fields
    @cameraAngles = new @constructor.ArrayField @, 'cameraAngles', @cameraAngles, @constructor.CameraAngle
    @objects = new @constructor.ArrayField @, 'objects', @objects, @constructor.Object
    @materials = new @constructor.ArrayField @, 'materials', @materials, @constructor.Material

    # After mesh is initialized, mark to be in saved state.
    @dirty false

    @_initialized = true

    return unless initializeRuntimeData

    # Reactively generate the lightmap
    @lightmap = new ReactiveField null

    # Initialize runtime data.
    @materialProperties = new @constructor.MaterialProperties @
    @lightmapAreaProperties = new @constructor.LightmapAreaProperties @

    Tracker.nonreactive =>
      @_generateLightmapAutorun = Tracker.autorun =>
        # Clean previous lightmap.
        @_lightmap?.destroy()
        @_lightmap = null

        # Make sure lightmap size isn't zero.
        return unless @lightmapAreaProperties.lightmapSize().width > 0

        @_lightmap = new LOI.Engine.Lightmap @
        @lightmap @_lightmap

    @paletteTexture = new LOI.Engine.Textures.Palette

    # Update palette data. We need to do it in an autorun to depend on palette changes.
    Tracker.nonreactive =>
      @_updatePaletteTextureAutorun = Tracker.autorun =>
        propertiesChangedDependency.depend()
        return unless palette = @customPalette or LOI.Assets.Palette.documents.findOne @palette._id
        @paletteTexture.update palette

  destroy: ->
    @_generateLightmapAutorun.stop()
    @_updatePaletteTextureAutorun.stop()

    @materialProperties.destroy()
    @lightmapAreaProperties.destroy()

  depend: ->
    @_updatedDependency.depend()

  contentUpdated: ->
    @dirty true
    @_updatedDependency.changed()

  save: ->
    saveData = @getManuallySavedData()

    # Send the mesh to server.
    LOI.Assets.Mesh.save @_id, saveData, (error) =>
      if error
        console.error "Error saving mesh", saveData, error

    # Mark the state clean.
    @dirty false

  getManuallySavedData: ->
    saveData = {}

    # Save array fields.
    @cameraAngles.save saveData
    @objects.save saveData
    @materials.save saveData

    saveData

  getLandmarkByName: (landmarkName) ->
    _.find @landmarks, (landmark) -> landmark.name is landmarkName

  getClusterByName: (clusterName) ->
    for object in @objects.getAll()
      for layer in object.layers.getAll()
        if cluster = layer.getClusterByName clusterName
          return cluster
          
    null

  getLandmarkPositionVector: (landmarkOrIndexOrName) ->
    if _.isString landmarkOrIndexOrName
      landmark = @getLandmarkByName landmarkOrIndexOrName

      unless landmark
        console.warn "Couldn't find landmark", landmarkOrIndexOrName
        return

    else if _.isNumber landmarkOrIndexOrName
      landmark = @landmarks[landmarkOrIndexOrName]

      unless landmark
        console.warn "Couldn't find landmark index", landmarkOrIndexOrName
        return

    else
      return unless landmark = landmarkOrIndexOrName

    return unless layer = @objects.get(landmark.object)?.layers.get(landmark.layer)
    return unless picture = layer.getPictureForCameraAngleIndex landmark.cameraAngle
    
    clusterId = picture.getClusterIdForPixel Math.round(landmark.x), Math.round(landmark.y)
    return unless clusterPlaneData = layer.clusters.get(clusterId).plane()
    return unless cameraAngle = @cameraAngles.get landmark.cameraAngle

    planeNormal = THREE.Vector3.fromObject clusterPlaneData.normal
    planePoint = THREE.Vector3.fromObject clusterPlaneData.point
    plane = new THREE.Plane().setFromNormalAndCoplanarPoint planeNormal, planePoint

    points = [
      x: landmark.x
      y: landmark.y
    ]

    cameraAngle.projectPoints(points, plane)[0]

  getSpriteBoundsAndLayersForCameraAngle: (cameraAngleIndex) ->
    spriteLayers = []
    spriteBounds = null

    # Rebuild layers from objects for camera angle.
    for object in @objects.getAll()
      {bounds, layers} = object.getSpriteBoundsAndLayersForCameraAngle cameraAngleIndex

      continue unless bounds

      boundsRectangle = AE.Rectangle.fromDimensions bounds

      if spriteBounds
        spriteBounds = spriteBounds.union boundsRectangle

      else
        spriteBounds = boundsRectangle

      spriteLayers.push layers...

    bounds: spriteBounds?.toObject()
    layers: spriteLayers

  getPreviewSprite: (cameraAngleIndex) ->
    @initialize() unless @_initialized

    cameraAngleIndex ?= @cameraAngles.getFirstIndex()
    {bounds, layers} = @getSpriteBoundsAndLayersForCameraAngle cameraAngleIndex

    # The sprite expects materials as a map instead of an array.
    materials = @materials.getAllAsIndexedMap()

    new LOI.Assets.Sprite
      palette: _.pick @palette, ['_id']
      layers: layers
      materials: materials
      bounds: bounds

  # Database content

  getSaveData: ->
    saveData = super arguments...

    _.extend saveData, _.pick @, ['cameraAngles', 'objects']

    if @_initialized
      saveData = _.omit saveData, ['cameraAngles', 'objects', 'materials']
      _.extend saveData, @getManuallySavedData()

    else
      # We refetch the mesh instead of simply send the @ reference because this
      # instance might get initialized later to generate the preview image.
      LOI.Assets.Mesh.documents.findOne @_id

  getPreviewImage: ->
    engineSprite = new LOI.Assets.Engine.Sprite
      spriteData: => @getPreviewSprite()

    engineSprite.getCanvas
      lightDirection: new THREE.Vector3 0, 0, -1
