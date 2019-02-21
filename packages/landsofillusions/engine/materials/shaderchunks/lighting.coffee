LOI = LandsOfIllusions

LOI.Engine.Materials.ShaderChunks.totalLightIntensity = """
  // Accumulate directional lights.
  float totalLightIntensity = 0.0;

  DirectionalLight directionalLight;
  float lightIntensity;
  float shadow;

  for (int i = 0; i < NUM_DIR_LIGHTS; i++) {
    directionalLight = directionalLights[i];

    // Shade using Lambert cosine law.
    lightIntensity = saturate(dot(directionalLight.direction, vNormal)) * directionalLight.color.r;

    shadow = 1.0;

    #ifdef USE_SHADOWMAP
      if (directionalLight.shadow > 0) {
        // Apply shadow map. For some reason we must address the map with a constant, not the index i.
        if (i==0) {
          shadow = getShadow(directionalShadowMap[0], directionalLight.shadowMapSize, directionalLight.shadowBias, directionalLight.shadowRadius, vDirectionalShadowCoord[0]);
        }
        #if NUM_DIR_LIGHTS > 1
          else if (i==1) {
            shadow = getShadow(directionalShadowMap[1], directionalLight.shadowMapSize, directionalLight.shadowBias, directionalLight.shadowRadius, vDirectionalShadowCoord[1]);
          }
        #endif
      }
    #endif

    // Add to total intensity.
    totalLightIntensity += lightIntensity * shadow;
  }
"""