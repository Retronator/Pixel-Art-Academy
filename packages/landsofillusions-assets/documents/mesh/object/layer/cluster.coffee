AE = Artificial.Everywhere
LOI = LandsOfIllusions

Pako = require 'pako'

compressionOptions =
  level: Pako.Z_BEST_COMPRESSION

class LOI.Assets.Mesh.Object.Layer.Cluster
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

    for field in ['properties', 'plane', 'material', 'geometry']
      @[field] = new LOI.Assets.Mesh.ValueField @, field, data[field]
      
  _decompressData: (compressedByteArray, arrayClass) ->
    byteArray = Pako.inflateRaw compressedByteArray
    new arrayClass byteArray.buffer

  toPlainObject: ->
    plainObject = {}

    @[field].save plainObject for field in ['properties', 'plane', 'material', 'geometry']

    # Compress geometry.
    plainObject.geometry =
      compressedVertices: @_compressArray plainObject.geometry.vertices
      compressedNormals: @_compressArray plainObject.geometry.normals
      compressedIndices: @_compressArray plainObject.geometry.indices

    plainObject
    
  _compressArray: (array) ->
    byteArray = new Uint8Array array.buffer
    Pako.deflateRaw byteArray, compressionOptions

  depend: ->
    @_updatedDependency.depend()

  contentUpdated: ->
    @_updatedDependency.changed()
    @layers.contentUpdated()
