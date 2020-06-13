LOI = LandsOfIllusions

class LOI.Engine.Skydome.Procedural.Material extends THREE.ShaderMaterial
  constructor: (options) ->
    parameters =
      depthWrite: false
      side: THREE.BackSide

      uniforms:
        resolution:
          value: options.resolution
        # We need UV transform added to correctly calculate UV coordinates (even if it's identity).
        uvTransform:
          value: new THREE.Matrix3
        map:
          value: null
        sunDirection:
          value: new THREE.Vector3 0, -1, 0

      vertexShader: '#include <LandsOfIllusions.Engine.Skydome.Material.vertex>'
      fragmentShader: '#include <LandsOfIllusions.Engine.Skydome.Procedural.Material.fragment>'

    super parameters
    @options = options

    # Mark as a PBR material so it gets rendered during radiance transfer.
    @pbr = true
