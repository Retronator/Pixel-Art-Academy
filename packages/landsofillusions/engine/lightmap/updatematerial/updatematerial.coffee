LOI = LandsOfIllusions

class LOI.Engine.Lightmap.UpdateMaterial extends THREE.RawShaderMaterial
  constructor: (options) ->
    parameters =
      glslVersion: THREE.GLSL3
      
      transparent: true

      # We want to preserve the alpha channel so we simply use the destination alpha.
      blending: THREE.CustomBlending
      blendDstAlpha: THREE.OneFactor
      blendSrcAlpha: THREE.ZeroFactor

      # We don't want to affect pixels that are not part of the cluster, so we multiply the source with lightmap alpha.
      # For blending to work properly, we'll premultiply the source color already in the shader to account for this.
      blendSrc: THREE.DstAlphaFactor
  
      uniforms:
        modelViewProjectionMatrix:
          value: options.modelViewProjectionMatrix
        probeOctahedronMap:
          value: LOI.Engine.Lightmap.Probe.octahedronMap
        probeOctahedronMapMaxLevel:
          value: LOI.Engine.Lightmap.Probe.octahedronMapMaxLevel
        blendFactor:
          value: 1

      vertexShader: '#include <LandsOfIllusions.Engine.Lightmap.UpdateMaterial.vertex>'
      fragmentShader: '#include <LandsOfIllusions.Engine.Lightmap.UpdateMaterial.fragment>'

    super parameters
    @options = options
