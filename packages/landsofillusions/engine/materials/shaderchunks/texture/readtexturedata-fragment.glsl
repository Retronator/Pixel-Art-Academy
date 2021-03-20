// LandsOfIllusions.Engine.Materials.readTextureDataFragment

vec2 spriteUv = vUv;

if (!powerOf2Texture) {
  // Wrap UV coordinates manually since we want to wrap a non-power-of-2 texture.
  spriteUv -= floor(vUv);
}

// Read palette color from main map.
vec4 mapSample = texture2D(map, spriteUv, mipmapBias);

// Discard transparent pixels.
if (mapSample.a == 0.0) discard;

#ifdef USE_NORMALMAP
// Read normal from normal map.
vec3 spriteNormal = texture2D(normalMap, spriteUv, mipmapBias).xyz * 2.0 - 1.0;

// Modify the surface normal based on the normal map.
normal = applyNormalMap(-vViewPosition, normal, spriteNormal);

#endif
