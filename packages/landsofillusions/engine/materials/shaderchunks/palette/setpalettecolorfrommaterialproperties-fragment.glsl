// LandsOfIllusions.Engine.Materials.setPaletteColorFromMaterialPropertiesFragment

float rampProperty = readMaterialProperty(materialPropertyRamp);
float shadeProperty = readMaterialProperty(materialPropertyShade);
paletteColor = (vec2(rampProperty, shadeProperty) + 0.5) / 256.0;
