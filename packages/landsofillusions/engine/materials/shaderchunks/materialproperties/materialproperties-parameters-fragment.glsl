// LandsOfIllusions.Engine.Materials.materialPropertiesParametersFragment

varying float vMaterialPropertiesIndex;
uniform sampler2D materialProperties;

// Correlates to the LandsOfIllusions.Engine.Textures.MaterialProperties constants.
const float maxMaterialProperties = 16.0;
const float materialPropertyPaletteColor = 0.5 / maxMaterialProperties;
const float materialPropertyDither = 1.5 / maxMaterialProperties;
const float materialPropertyReflection = 2.5 / maxMaterialProperties;
const float materialPropertyTranslucency = 3.5 / maxMaterialProperties;
const float materialPropertyTranslucencyShadow = 4.5 / maxMaterialProperties;
const float materialPropertyReflectance = 5.5 / maxMaterialProperties;
const float materialPropertyEmission = 6.5 / maxMaterialProperties;
const float materialPropertyRefractiveIndex = 7.5 / maxMaterialProperties;
const float materialPropertyStructure = 8.5 / maxMaterialProperties;

float readMaterialProperty(float property) {
  return texture2D(materialProperties, vec2(vMaterialPropertiesIndex, property)).r;
}

vec2 readMaterialProperty2(float property) {
  return texture2D(materialProperties, vec2(vMaterialPropertiesIndex, property)).rg;
}

vec3 readMaterialProperty3(float property) {
  return texture2D(materialProperties, vec2(vMaterialPropertiesIndex, property)).rgb;
}

vec4 readMaterialProperty4(float property) {
  return texture2D(materialProperties, vec2(vMaterialPropertiesIndex, property)).rgba;
}
