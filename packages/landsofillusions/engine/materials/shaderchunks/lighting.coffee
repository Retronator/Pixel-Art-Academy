LOI = LandsOfIllusions

LOI.Engine.Materials.ShaderChunks.totalLightIntensityParametersFragment = """
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
"""

LOI.Engine.Materials.ShaderChunks.totalLightIntensityFragment = """
  // Accumulate directional lights.
  float totalLightIntensity = 0.0;
  float totalReflectedLightIntensity = 0.0;

  DirectionalLight directionalLight;
  float lightIntensity;
  vec4 shadowColor;

  vec3 viewDirection = normalize(vViewPosition);

  // Note: Unrolling a loop requires specific whitespace formatting.
  #pragma unroll_loop
  for ( int i = 0; i < NUM_DIR_LIGHTS; i ++ ) {

    directionalLight = directionalLights[ i ];

    // Shade using Lambert cosine law.
    lightIntensity = saturate(dot(directionalLight.direction, normal)) * directionalLight.color.r;

    // Apply specular highlight.
    // Note: We don't use parenthesis since the pragma unroll would match them and close the unroll.
    if (reflectionParameters.x > 0.0) totalReflectedLightIntensity += calculateReflectionIntensity(reflectionParameters, directionalLight, normal, viewDirection);

    #ifdef USE_SHADOWMAP
      shadowColor = getShadowColor(directionalShadowMap[ i ], directionalOpaqueShadowMap[ i ], directionalShadowColorMap[ i ], directionalLight.shadowBias + shadowBiasOffset, vDirectionalShadowCoord[ i ]);

    #else
      // We aren't using shadows, let all the light go through (full translucency).
      shadowColor = vec4(1.0, 1.0, 0.0, 1.0);

    #endif

    // Add to total intensity.
    totalLightIntensity += lightIntensity * shadowColor.a;

    // Tint the fragment if shadow color is set.
    // Note: We don't use parenthesis since the pragma unroll would match them and close the unroll.
    if (shadowColor.r < 1.0) paletteColor.r = (shadowColor.r * 255.0 + 0.5) / 256.0;

  }

"""

LOI.Engine.Materials.ShaderChunks.shadeSourceColorFragment = """
  // Shade from ambient to full light based on intensity.
  float shadeFactor = mix(ambientLightColor.r, 1.0, totalLightIntensity);
  vec3 shadedColor = sourceColor * shadeFactor + vec3(1) * totalReflectedLightIntensity;
"""
