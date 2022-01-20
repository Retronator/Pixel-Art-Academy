LOI = LandsOfIllusions

class LOI.Engine.Materials.SpriteMaterial extends THREE.ShaderMaterial
  constructor: (options = {}) ->
    super
      lights: true
      side: THREE.DoubleSide
      shadowSide: THREE.DoubleSide

      uniforms: _.extend
        # Globals
        renderSize:
          value: new THREE.Vector2

        # Color information
        palette:
          value: LOI.paletteTexture

        # Shading
        smoothShading:
          value: options.smoothShading or false
        colorQuantizationFactor:
          value: options.colorQuantizationFactor
        directionalShadowColorMap:
          value: []
        directionalOpaqueShadowMap:
          value: []
        preprocessingMap:
          value: null

        # Texture
        map:
          value: null
        normalMap:
          value: null
        uvTransform:
          value: new THREE.Matrix3
      ,
        THREE.UniformsLib.lights

      vertexShader: "#include <LandsOfIllusions.Engine.Materials.SpriteMaterial.vertex>"
      fragmentShader: "#include <LandsOfIllusions.Engine.Materials.SpriteMaterial.fragment>"

    @options = options
