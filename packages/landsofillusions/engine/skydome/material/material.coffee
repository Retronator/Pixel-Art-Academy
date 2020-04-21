LOI = LandsOfIllusions

class LOI.Engine.Skydome.Material extends THREE.ShaderMaterial
  constructor: (options) ->
    parameters =
      depthWrite: false
      side: THREE.BackSide
      dithering: true

      uniforms:
        resolution:
          value: options.resolution
        uvTransform:
          value: new THREE.Matrix3
        map:
          value: options.map
        sunDirection:
          value: new THREE.Vector3 0, -1, 0

      vertexShader: '#include <LandsOfIllusions.Engine.Skydome.Material.vertex>'
      fragmentShader: '#include <LandsOfIllusions.Engine.Skydome.Material.fragment>'

    super parameters
    @options = options

    # Also set the map onto the material so that proper shader defines get set.
    @map = options.map

    # Mark as a PBR material so it gets rendered during radiance transfer.
    @pbr = true
