LOI = LandsOfIllusions

class LOI.Engine.IlluminationState.ProbeMapAtlas
  constructor: (@mesh) ->
    layerAtlasSize = @mesh.layerProperties.layerAtlasSize()
    @width = layerAtlasSize.width
    @height = layerAtlasSize.height

    # Map which pixels are present in the cluster.
    @distanceMap = new Int32Array @width * @height

    @probeMaps = []
    @currentProbeMapIndex = 0

    dataArray = new Float32Array @width * @height
    @texture = new THREE.DataTexture dataArray, @width, @height, THREE.AlphaFormat, THREE.FloatType

    for object in @mesh.objects.getAllWithoutUpdates() when object?.visible()
      for layer in object.layers.getAllWithoutUpdates() when layer?.visible()
        probeMap = new LOI.Engine.IlluminationState.ProbeMap @, layer
        @probeMaps.push probeMap

  writeToPixel: (x, y, value) ->
    pixelIndex = x + y * @width
    @texture.image.data[pixelIndex] = value
    @texture.needsUpdate = true

  getNewUpdatePixel: ->
    # Find probe map with lowest completeness.
    probeMap = _.minBy @probeMaps, (probeMap) => probeMap.completeness()
    probeMap.getNewUpdatePixel()

  debugOutput: ->
    probeMap.debugOutput() for probeMap in @probeMaps
