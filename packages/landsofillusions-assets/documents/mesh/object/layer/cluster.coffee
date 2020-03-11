AE = Artificial.Everywhere
LOI = LandsOfIllusions

Pako = require 'pako'

compressionOptions =
  level: Pako.Z_BEST_COMPRESSION

_planeNormal = new THREE.Vector3()
_planePoint = new THREE.Vector3()

class LOI.Assets.Mesh.Object.Layer.Cluster
  @AttachmentTypes:
    Contact: 'contact'
    Fixed: 'fixed'

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

    for field in ['properties', 'plane', 'material', 'geometry', 'boundsInPicture']
      @[field] = new LOI.Assets.Mesh.ValueField @, field, data[field]

    @planeHelper = new THREE.Plane
    @_updatePlaneHelper()

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

    plainObject
    
  _compressArray: (array) ->
    byteArray = new Uint8Array array.buffer
    Pako.deflateRaw byteArray, compressionOptions

  depend: ->
    @_updatedDependency.depend()

  contentUpdated: ->
    @_updatePlaneHelper()

    @_updatedDependency.changed()
    @layers.contentUpdated()

  _updatePlaneHelper: ->
    return unless plane = @plane()

    _planeNormal.copy plane.normal
    _planePoint.copy plane.point
    @planeHelper.setFromNormalAndCoplanarPoint _planeNormal, _planePoint
