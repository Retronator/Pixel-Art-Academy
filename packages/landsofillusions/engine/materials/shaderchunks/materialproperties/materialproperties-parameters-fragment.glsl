// LandsOfIllusions.Engine.Materials.materialPropertiesParametersFragment

varying float vMaterialPropertiesIndex;
uniform sampler2D materialProperties;

// Correlates to the LandsOfIllusions.Engine.Textures.MaterialProperties constants.
const float maxMaterialProperties = 16.0;
const float materialPropertyRamp = 0.5 / maxMaterialProperties;
const float materialPropertyShade = 1.5 / maxMaterialProperties;
const float materialPropertyDither = 2.5 / maxMaterialProperties;
const float materialPropertyReflectionIntensity = 3.5 / maxMaterialProperties;
const float materialPropertyReflectionShininess = 4.5 / maxMaterialProperties;
const float materialPropertyReflectionSmoothFactor = 5.5 / maxMaterialProperties;
const float materialPropertyTranslucencyAmount = 6.5 / maxMaterialProperties;
const float materialPropertyTranslucencyDither = 7.5 / maxMaterialProperties;
const float materialPropertyTranslucencyTint = 8.5 / maxMaterialProperties;
const float materialPropertyTranslucencyShadowDither = 9.5 / maxMaterialProperties;
const float materialPropertyTranslucencyShadowTint = 10.5 / maxMaterialProperties;

float readMaterialProperty(float property) {
  return texture2D(materialProperties, vec2(vMaterialPropertiesIndex, property)).a;
}

