// LandsOfIllusions.Engine.Materials.totalLightIntensityParametersFragment

#ifdef USE_SHADOWMAP
  #if NUM_DIR_LIGHTS > 0
    uniform sampler2D directionalShadowColorMap[NUM_DIR_LIGHTS];
    uniform sampler2D directionalOpaqueShadowMap[NUM_DIR_LIGHTS];
  #endif

  vec4 getShadowColor(sampler2D shadowMap, sampler2D opaqueShadowMap, sampler2D shadowColorMap, float shadowBias, vec4 shadowCoord) {
    vec4 shadowColor = vec4(1.0, 1.0, 0.0, 1.0);

    shadowCoord.xyz /= shadowCoord.w;
    shadowCoord.z += shadowBias;

    bvec4 inFrustumVec = bvec4 (shadowCoord.x >= 0.0, shadowCoord.x <= 1.0, shadowCoord.y >= 0.0, shadowCoord.y <= 1.0);
    bool inFrustum = all(inFrustumVec);

    bvec2 frustumTestVec = bvec2(inFrustum, shadowCoord.z <= 1.0);

    bool frustumTest = all(frustumTestVec);

    if (frustumTest) {
      // See if we are in full opaque shadow.
      float opaqueShadowFactor = texture2DCompare(opaqueShadowMap, shadowCoord.xy, shadowCoord.z);

      if (opaqueShadowFactor < 1.0) {
        // We're behind a fully opaque object. Don't let any light get transmitted through.
        shadowColor.a = 0.0;

      } else {
        // See if we are in translucent shadow.
        float translucentShadowFactor = texture2DCompare(shadowMap, shadowCoord.xy, shadowCoord.z);

        if (translucentShadowFactor < 1.0) {
          // We're in translucent shadow so get shadow color. The parameters are:
          // r: shadow ramp
          // g: shadow shade
          // b: shadow dither amount
          // a: shadow translucency (light transmission)
          shadowColor = texture2D(shadowColorMap, shadowCoord.xy);

          // See if shadow has a dither.
          if (shadowColor.b > 0.0) {
            // Make the shadow fully transparent at this pixel according to the dithering pattern.
            if (dither4levels(shadowColor.b)) {
              shadowColor.r = 1.0;
              shadowColor.a = 1.0;
            }
          }
        }
      }
    }

    return shadowColor;
  }
#endif

float calculateReflectionIntensity(vec3 reflectionParameters, DirectionalLight directionalLight, vec3 normal, vec3 viewDirection) {
  vec3 reflection = reflect(-directionalLight.direction, normal);
  float reflectionViewProduct = saturate(dot(reflection, viewDirection));
  float reflectionLightFactor = pow(reflectionViewProduct, reflectionParameters.y) * reflectionParameters.x;
  return reflectionLightFactor * directionalLight.color.r;
}
