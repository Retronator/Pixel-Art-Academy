// LandsOfIllusions.Engine.IlluminationState.commonParametersFragment

#ifdef USE_LIGHTMAP
  uniform vec2 lightmapSize;

  vec3 sampleLightmapMinMax(vec2 position, float mipmapLevel, vec2 areaMin, vec2 areaMax) {
    position = clamp(position, areaMin, areaMax);
    return texture2DLodEXT(lightMap, position, mipmapLevel).rgb;
  }

  vec3 sampleLightmap(vec2 position, float mipmapLevel, vec2 areaPosition, float areaSize) {
    // Clamp position to prevent bleed across areas.
    float higherMipmapLevel = ceil(mipmapLevel);
    float levelFactor = pow(2.0, higherMipmapLevel);
    vec2 pixelMin = areaPosition + 0.5 * levelFactor;
    vec2 pixelMax = areaPosition + vec2(areaSize) - 0.5 * levelFactor;
    vec2 areaMin = pixelMin / lightmapSize;
    vec2 areaMax = pixelMax / lightmapSize;

    return sampleLightmapMinMax(position, mipmapLevel, areaMin, areaMax);
  }
#endif
