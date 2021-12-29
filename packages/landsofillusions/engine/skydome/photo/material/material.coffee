LOI = LandsOfIllusions

class LOI.Engine.Skydome.Photo.Material extends THREE.ShaderMaterial
  constructor: (options) ->
    parameters =
      depthWrite: false
      side: THREE.BackSide

      uniforms:
        # We need UV transform added to correctly calculate UV coordinates (even if it's identity).
        uvTransform:
          value: new THREE.Matrix3
        map:
          value: new THREE.DataTexture

      vertexShader: '#include <LandsOfIllusions.Engine.Skydome.Material.vertex>'
      fragmentShader: '#include <LandsOfIllusions.Engine.Skydome.Photo.Material.fragment>'

    super parameters
    @options = options

    # Set a temporary map onto the material so that proper shader defines get set.
    @map = new THREE.DataTexture

    # Mark as a PBR and GI material so it gets rendered during radiance transfer.
    @pbr = true
    @gi = true
