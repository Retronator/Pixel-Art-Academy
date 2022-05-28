AE = Artificial.Everywhere
LOI = LandsOfIllusions

Pako = require 'pako'

compressionOptions =
  level: Pako.Z_BEST_COMPRESSION

class LOI.Assets.Mesh.Object.Layer.Cluster
  @AttachmentTypes:
    Contact: 'Contact'

  @createPlaneBasis: (normal, rightHanded, result) ->
    result ?= new THREE.Matrix4

    # Create the base of plane space.
    plane = new THREE.Plane normal, 0

    unitX = if Math.abs(normal.x) is 1 then new THREE.Vector3 0, 0, 1 else new THREE.Vector3 1, 0, 0
    baseX = new THREE.Vector3
    plane.projectPoint unitX, baseX
    baseX.normalize()

    baseY = new THREE.Vector3().crossVectors normal, baseX
    baseY.multiplyScalar(-1) if rightHanded

    result.makeBasis baseX, baseY, normal

    result

  @createPlaneWorldMatrix: (plane, rightHanded, result) ->
    result ?= new THREE.Matrix4
    @createPlaneBasis plane.normal, rightHanded, result
    result.setPosition plane.point
    result

  constructor: (@layers, id, data) ->
    @layer = @layers.parent
    @id = parseInt id

    @_updatedDependency = new Tracker.Dependency

    if data.geometry
      # Decompress geometry.
      data.geometry =
        vertices: @_decompressData data.geometry.compressedVertices, Float32Array
        normals: @_decompressData data.geometry.compressedNormals, Float32Array
        indices: @_decompressData data.geometry.compressedIndices, Uint32Array
        pixelCoordinates: @_decompressData data.geometry.compressedPixelCoordinates, Float32Array
        layerPixelCoordinates: @_decompressData data.geometry.compressedLayerPixelCoordinates, Float32Array

    for field in ['properties', 'plane', 'material', 'geometry', 'boundsInPicture']
      @[field] = new LOI.Assets.Mesh.ValueField @, field, data[field]

    @planeHelper = new THREE.Plane
    @planeBasis = new THREE.Matrix4
    @planeWorldMatrix = new THREE.Matrix4
    @planeWorldMatrixInverse = new THREE.Matrix4
    @_updatePlaneHelpers()

  _decompressData: (compressedByteArray, arrayClass) ->
    return unless compressedByteArray

    byteArray = Pako.inflateRaw compressedByteArray
    new arrayClass byteArray.buffer

  toPlainObject: ->
    plainObject = {}

    @[field].save plainObject for field in ['properties', 'plane', 'material', 'geometry', 'boundsInPicture']

    # Compress geometry.
    plainObject.geometry =
      compressedVertices: @_compressArray plainObject.geometry.vertices
      compressedNormals: @_compressArray plainObject.geometry.normals
      compressedIndices: @_compressArray plainObject.geometry.indices
      compressedPixelCoordinates: @_compressArray plainObject.geometry.pixelCoordinates
      compressedLayerPixelCoordinates: @_compressArray plainObject.geometry.layerPixelCoordinates

    plainObject
    
  _compressArray: (array) ->
    byteArray = new Uint8Array array.buffer
    Pako.deflateRaw byteArray, compressionOptions

  depend: ->
    @_updatedDependency.depend()

  contentUpdated: ->
    @_updatePlaneHelpers()

    @_updatedDependency.changed()
    @layers.contentUpdated()

  isVisible: ->
    @layer.isVisible()

  _updatePlaneHelpers: ->
    return unless plane = @plane()

    # Convert plane data into objects.
    plane =
      normal: new THREE.Vector3().copy plane.normal
      point: new THREE.Vector3().copy plane.point

    @planeHelper.setFromNormalAndCoplanarPoint plane.normal, plane.point

    @constructor.createPlaneBasis plane.normal, false, @planeBasis
    @constructor.createPlaneWorldMatrix plane, false, @planeWorldMatrix
    @planeWorldMatrixInverse.copy(@planeWorldMatrix).invert()
