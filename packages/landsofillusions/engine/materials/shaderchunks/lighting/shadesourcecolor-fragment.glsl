// LandsOfIllusions.Engine.Materials.shadeSourceColorFragment

// Shade from ambient to full light based on intensity.
float shadeFactor = mix(ambientLightColor.r, 1.0, totalLightIntensity);
vec3 shadedColor = sourceColor * shadeFactor + vec3(1) * totalReflectedLightIntensity;
