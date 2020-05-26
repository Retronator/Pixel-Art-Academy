// LandsOfIllusions.Engine.Materials.mapTextureVertex

#ifdef USE_MAP
  // Map the texture from position to UV coordinates.
  vec3 mappedPosition = textureMapping * position;

  // Set the z coordinate to 1 so we can apply the UV transform.
  mappedPosition.z = 1.0;
  vUv = (uvTransform * mappedPosition).xy;
#endif
