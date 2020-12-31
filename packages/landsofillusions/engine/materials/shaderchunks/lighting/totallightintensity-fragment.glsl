// LandsOfIllusions.Engine.Materials.totalLightIntensityFragment

// Accumulate directional lights.
float totalLightIntensity = 0.0;
float totalReflectedLightIntensity = 0.0;

DirectionalLight directionalLight;

#ifdef USE_SHADOWMAP
  DirectionalLightShadow directionalLightShadow;
#endif

float lightIntensity;
vec4 shadowColor;

vec3 viewDirection = normalize(vViewPosition);

// Note: Unrolling a loop requires specific whitespace formatting.
#pragma unroll_loop_start
for ( int i = 0; i < NUM_DIR_LIGHTS; i ++ ) {

  directionalLight = directionalLights[ i ];

  // Shade using Lambert cosine law.
  lightIntensity = saturate(dot(directionalLight.direction, normal)) * directionalLight.color.r;

  // Apply specular highlight.
  // Note: We don't use parenthesis since the pragma unroll would match them and close the unroll.
  if (reflectionParameters.x > 0.0) totalReflectedLightIntensity += calculateReflectionIntensity(reflectionParameters, directionalLight, normal, viewDirection);

  #ifdef USE_SHADOWMAP
    directionalLightShadow = directionalLightShadows[ i ];
    shadowColor = getShadowColor(directionalShadowMap[ i ], directionalOpaqueShadowMap[ i ], directionalShadowColorMap[ i ], directionalLightShadow.shadowBias + shadowBiasOffset, vDirectionalShadowCoord[ i ]);

  #else
    // We aren't using shadows, let all the light go through (full translucency).
    shadowColor = vec4(1.0, 1.0, 0.0, 1.0);

  #endif

  // Add to total intensity.
  totalLightIntensity += lightIntensity * shadowColor.a;

  // Tint the fragment if shadow color is set.
  if (shadowColor.r < 1.0) {
    paletteColor.r = (shadowColor.r * 255.0 + 0.5) / 256.0;
  }

}
#pragma unroll_loop_end
