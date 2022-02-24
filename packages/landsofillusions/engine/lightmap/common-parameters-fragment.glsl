// LandsOfIllusions.Engine.Lightmap.commonParametersFragment
uniform sampler2D lightmap;
uniform vec2 lightmapSize;

vec3 sampleLightmapMinMax(vec2 position, float mipmapLevel, vec2 areaMin, vec2 areaMax) {
  position = clamp(position, areaMin, areaMax);
  vec4 value = textureLod(lightmap, position, mipmapLevel);
  vec3 irradiance = value.rgb;

  // The mipmaped value needs to be weighted by the alpha channel, so that empty pixels don't attribute to the average
  // color. We can only do this on pixels that fall inside the lightmap area (some parts of triangles on a sub-pixel
  // level can fall outside the lightmap).
  if (value.a > 0.0) {
    irradiance /= value.a;
  }

  return irradiance;
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
