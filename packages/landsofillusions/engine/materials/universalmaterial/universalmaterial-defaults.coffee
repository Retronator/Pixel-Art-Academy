LOI = LandsOfIllusions

LOI.Engine.Materials.UniversalMaterial.defaults =
  ramp: 0
  shade: 0
  dither: 1
  reflection:
    intensity: 0
    shininess: 1
    smoothFactor: 0
  translucency:
    amount: 0
    dither: 0
    tint: false
    blending:
      preset: THREE.NormalBlending
      equation: THREE.AddEquation
      sourceFactor: THREE.SrcAlphaFactor
      destinationFactor: THREE.OneMinusSrcAlphaFactor
    shadow:
      # Note: Shadow dither by default matches translucency dither.
      dither: null
      tint: false
  materialClass: null
  refractiveIndex:
    r: 1.5
    g: 0
    b: 0
  temperature: 0
  emission:
    r: 0
    g: 0
    b: 0
  reflectance:
    r: 0
    g: 0
    b: 0
  surfaceRoughness: 1
  subsurfaceHeterogeneity: 1
  conductivity: 0
  texture: null
