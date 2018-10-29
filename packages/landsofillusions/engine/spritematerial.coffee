LOI = LandsOfIllusions

class LOI.Engine.SpriteMaterial extends THREE.ShaderMaterial
  # Create the modified Atari 2600 palette texture.
  @rampsCount = 16
  @shadesCount = 10
  @paletteData = new Uint8Array @rampsCount * @shadesCount * 3
  @paletteTexture = new THREE.DataTexture @paletteData, @rampsCount, @shadesCount, THREE.RGBFormat

  Meteor.startup ->
    Tracker.autorun (computation) ->
      return unless palette = LOI.palette()
      computation.stop()

      SpriteMaterial = LOI.Engine.SpriteMaterial

      for ramp, rampIndex in palette.ramps
        for shade, shadeIndex in ramp.shades
          palettePixelIndex = rampIndex + SpriteMaterial.rampsCount * shadeIndex

          SpriteMaterial.paletteData[palettePixelIndex * 3] = shade.r * 255
          SpriteMaterial.paletteData[palettePixelIndex * 3 + 1] = shade.g * 255
          SpriteMaterial.paletteData[palettePixelIndex * 3 + 2] = shade.b * 255

      SpriteMaterial.paletteTexture.needsUpdate = true

  constructor: (@options = {}) ->
    super
      transparent: true
      lights: true
      shadowSide: THREE.DoubleSide

      uniforms: _.extend
        palette:
          value: LOI.Engine.SpriteMaterial.paletteTexture
        map:
          value: null
        normalMap:
          value: null
      ,
        THREE.UniformsLib.lights

      vertexShader: """
#include <common>
#include <uv_pars_vertex>
#include <shadowmap_pars_vertex>

void main()	{
  // Transform position.
  vec4 worldPosition = modelMatrix * vec4(position, 1.0);
  gl_Position = projectionMatrix * viewMatrix * worldPosition;

  // Send through UV coordinates.
  vUv = uv;

  // Compute shadow map.
	#include <shadowmap_vertex>
}
"""

      fragmentShader: """
#include <common>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <normalmap_pars_fragment>
#include <packing>
#include <lights_pars_begin>
#include <shadowmap_pars_fragment>

uniform mat4 modelViewMatrix;
uniform sampler2D palette;

void main()	{
  vec4 rampShadeDitherAlpha = texture2D(map, vUv);
  vec3 sourceColor = texture2D(palette, rampShadeDitherAlpha.rg).rgb;

  vec3 normal = texture2D(normalMap, vUv).xyz;
  vec3 normalEye = normalize((modelViewMatrix * vec4(normal, 0.0)).xyz);

  // Accumulate directional lights.
  float totalLightIntensity = 0.0;

  DirectionalLight directionalLight;
  float lightIntensity;
  float shadow;

  for (int i = 0; i < NUM_DIR_LIGHTS; i++) {
    directionalLight = directionalLights[i];

    // Shade using Lambert cosine law.
    lightIntensity = saturate(dot(directionalLight.direction, normalEye));

    // Apply shadow map. For some reason we must address the map with a constant, not the index i.
    if (i==0) {
      shadow = getShadow(directionalShadowMap[0], directionalLight.shadowMapSize, directionalLight.shadowBias, directionalLight.shadowRadius, vDirectionalShadowCoord[0]);
    }
    #if NUM_DIR_LIGHTS > 1
      else if (i==1) {
        shadow = getShadow(directionalShadowMap[1], directionalLight.shadowMapSize, directionalLight.shadowBias, directionalLight.shadowRadius, vDirectionalShadowCoord[1]);
      }
    #endif

    // Add to total intensity.
    totalLightIntensity += lightIntensity * shadow;
  }

  // Shade from ambient to full light based on intensity.
  float shadeFactor = mix(ambientLightColor.r, 1.0, totalLightIntensity);

  // Dim the color of the cluster by the shade factor.
  vec3 shadedColor = sourceColor * shadeFactor;

  // Find the nearest color from the palette to represent the shaded color.
  vec2 shadeUv = rampShadeDitherAlpha.rg;
  vec3 bestColor;
  vec3 secondBestColor;
  float bestColorDistance = 1000000.0;
  float secondBestColorDistance = 1000000.0;

  for (int shadeIndex = 0; shadeIndex < #{LOI.Engine.SpriteMaterial.shadesCount}; shadeIndex++) {
    shadeUv.g = float(shadeIndex) / #{LOI.Engine.SpriteMaterial.shadesCount}.0;
    vec3 shade = texture2D(palette, shadeUv).rgb;

    // Measure distance to color. We intentionally use squared distance.
    float distance = distance(shade, shadedColor);

    if (distance < bestColorDistance) {
      secondBestColor = bestColor;
      secondBestColorDistance = bestColorDistance;
      bestColor = shade;
      bestColorDistance = distance;
    } else if (distance < secondBestColorDistance) {
      secondBestColor = shade;
      secondBestColorDistance = distance;
    }
  }

  vec3 destinationColor = bestColor;

  // Apply dithering.
  float ditherPercentage = 2.0 * bestColorDistance / (bestColorDistance + secondBestColorDistance);

  int x = int(mod(gl_FragCoord.x, 2.0));
  int y = int(mod(gl_FragCoord.y, 2.0));

  if (ditherPercentage > 1.0 - rampShadeDitherAlpha.b) {
    if (x==y) {
      destinationColor = secondBestColor;
    }
  } //else {
    // Apply smooth shading.
    //float blendFactor = bestColorDistance / (bestColorDistance + secondBestColorDistance);
    //destinationColor = mix(bestColor, secondBestColor, blendFactor);
  //}

  // Color the pixel with the best match from the palette.
  gl_FragColor = vec4(destinationColor, rampShadeDitherAlpha.a);
}
"""
