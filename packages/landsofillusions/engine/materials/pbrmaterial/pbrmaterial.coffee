AR = Artificial.Reality
AP = Artificial.Pyramid
LOI = LandsOfIllusions

class LOI.Engine.Materials.PBRMaterial extends LOI.Engine.Materials.Material
  @id: -> 'LandsOfIllusions.Engine.Materials.PBRMaterial'
  @initialize()

  constructor: (options) ->
    parameters =
      lights: false

      uniforms: _.extend
        # Globals
        renderSize:
          value: new THREE.Vector2 1, 1
        cameraAngleMatrix:
          value: new THREE.Matrix4
        cameraParallelProjection:
          value: false
        cameraDirection:
          value: new THREE.Vector3

        # Cluster information
        clusterSize:
          value: options.clusterSize
        clusterPlaneWorldMatrix:
          value: options.clusterPlaneWorldMatrix
        clusterPlaneWorldMatrixInverse:
          value: options.clusterPlaneWorldMatrixInverse

      ,
        # Texture
        LOI.Engine.Materials.RampMaterial.getTextureUniforms options
      ,
        normalMap:
          value: null
        normalScale:
          value: new THREE.Vector2 1, 1
      ,
        # Radiance state
        radianceAtlasProbeLevel:
          value: LOI.Engine.RadianceState.radianceAtlasProbeLevel
        radianceAtlasProbeResolution:
          value: LOI.Engine.RadianceState.radianceAtlasProbeResolution
        radianceAtlasIn:
          value: null
        radianceAtlasOut:
          value: null
        probeMap:
          value: null

    super parameters
    @options = options

    LOI.Engine.Materials.RampMaterial.updateTextures @ if @options.texture

    # Update radiance state.
    Tracker.nonreactive =>
      Tracker.autorun =>
        return unless radianceState = @options.radianceStateField()

        @uniforms.radianceAtlasIn.value = radianceState.radianceAtlas.in.texture
        @uniforms.radianceAtlasOut.value = radianceState.radianceAtlas.out.texture
        @uniforms.probeMap.value = radianceState.probeMap.texture

        @needsUpdate = true
        @_dependency.changed()
