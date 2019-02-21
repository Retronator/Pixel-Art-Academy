LOI = LandsOfIllusions

class LOI.Engine.Materials.SpriteMaterial extends THREE.ShaderMaterial
  # Create the modified Atari 2600 palette texture.
  @rampsCount = 16
  @shadesCount = 10
  @paletteData = new Uint8Array @rampsCount * @shadesCount * 3
  @paletteTexture = new THREE.DataTexture @paletteData, @rampsCount, @shadesCount, THREE.RGBFormat

  Meteor.startup ->
    Tracker.autorun (computation) ->
      return unless palette = LOI.palette()
      computation.stop()

      SpriteMaterial = LOI.Engine.Materials.SpriteMaterial

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
      side: THREE.DoubleSide
      shadowSide: THREE.DoubleSide

      uniforms: _.extend
        palette:
          value: LOI.Engine.Materials.SpriteMaterial.paletteTexture
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
  // Send through UV coordinates.
  vUv = uv;

  #include <begin_vertex>
	#include <project_vertex>
  #include <worldpos_vertex>
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
  rampShadeDitherAlpha.g *= 12.75;
  vec3 sourceColor = texture2D(palette, rampShadeDitherAlpha.rg).rgb;

  vec3 normal = texture2D(normalMap, vUv).xyz;
  normal = (normal - 0.5) * 2.0;
  vec3 vNormal = normalize((modelViewMatrix * vec4(normal, 0.0)).xyz);

  #{LOI.Engine.Materials.ShaderChunks.totalLightIntensity}

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

  for (int shadeIndex = 0; shadeIndex < #{LOI.Engine.Materials.SpriteMaterial.shadesCount}; shadeIndex++) {
    shadeUv.g = float(shadeIndex) / #{LOI.Engine.Materials.SpriteMaterial.shadesCount}.0;
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

  if (rampShadeDitherAlpha.a < 0.5) discard;
}
"""
