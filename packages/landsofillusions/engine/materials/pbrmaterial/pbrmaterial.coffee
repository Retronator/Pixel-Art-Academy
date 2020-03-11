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
          value: null

        # Cluster information
        clusterSize:
          value: options.clusterSize

        # Material information
        refractiveIndex:
          value: options.refractiveIndex
        extinctionCoefficient:
          value: options.extinctionCoefficient
        emission:
          value: options.emission

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
        probeResolution:
          value: LOI.Engine.RadianceState.probeResolution
        radianceMap:
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

        @uniforms.radianceMap.value = radianceState.radianceAtlas.out.texture

        @needsUpdate = true
        @_dependency.changed()
