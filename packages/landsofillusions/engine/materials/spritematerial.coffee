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

  constructor: (options = {}) ->
    super
      transparent: true
      lights: true
      side: THREE.DoubleSide
      shadowSide: THREE.DoubleSide

      uniforms: _.extend
        uvTransform:
          value: new THREE.Matrix3
        palette:
          value: LOI.Engine.Materials.SpriteMaterial.paletteTexture
        map:
          value: null
        normalMap:
          value: null
        smoothShading:
          value: options.smoothShading
      ,
        THREE.UniformsLib.lights

      vertexShader: """
#include <common>
#include <uv_pars_vertex>
#include <shadowmap_pars_vertex>

void main()	{
	#include <uv_vertex>
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
uniform bool smoothShading;

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
  vec2 paletteColor = rampShadeDitherAlpha.rg;
  vec3 bestColor;
  float bestColorDistance;

  bool passedZero = false;
  vec3 earlierColor;
  vec3 laterColor;
  float blendFactor = 0.0;

  vec3 previousColor;
  float previousSignedDistance;

  for (int shadeIndex = 0; shadeIndex < #{LOI.Engine.Materials.SpriteMaterial.shadesCount}; shadeIndex++) {
    paletteColor.g = float(shadeIndex) / #{LOI.Engine.Materials.SpriteMaterial.shadesCount}.0;
    vec3 shade = texture2D(palette, paletteColor).rgb;

    // Measure distance to color.
    vec3 difference = shade - shadedColor;
    float signedDistance = difference.x + difference.y + difference.z;
    float distance = abs(difference.x) + abs(difference.y) + abs(difference.z);

    if (shadeIndex == 0) {
      // Set initial values in first loop iteration.
      bestColor = shade;
      bestColorDistance = distance;
      earlierColor = shade;
      laterColor = shade;
    } else {
      // See if we've crossed zero distance, which means our target shaded color is between the previous and current shade.
      if (previousSignedDistance < 0.0 && signedDistance >= 0.0 || previousSignedDistance >= 0.0 && signedDistance < 0.0) {
        passedZero = true;
        earlierColor = previousColor;
        laterColor = shade;
        blendFactor = abs(previousSignedDistance) / abs(signedDistance - previousSignedDistance);
      }

      if (distance < bestColorDistance) {
        bestColor = shade;
        bestColorDistance = distance;

      // Note: We have to make sure the distance increased since there could be two of the same colors in the palette.
      } else if (distance > bestColorDistance) {
        // We have increased the distance, which means we're moving away from the best color and can safely quit.
        break;
      }
    }

    previousSignedDistance = signedDistance;
    previousColor = shade;
  }

  vec3 destinationColor = bestColor;

  // Apply dithering.
  int x = int(mod(gl_FragCoord.x, 2.0));
  int y = int(mod(gl_FragCoord.y, 2.0));

  if (abs(0.5 - blendFactor) < rampShadeDitherAlpha.b / 2.0) {
    if (x==y) {
      destinationColor = earlierColor;
    } else {
      destinationColor = laterColor;
    }
  } else if (smoothShading && passedZero) {
    destinationColor = mix(earlierColor, laterColor, blendFactor);
  }

  // Color the pixel with the best match from the palette.
  gl_FragColor = vec4(destinationColor, rampShadeDitherAlpha.a);

  if (rampShadeDitherAlpha.a < 0.5) discard;
}
"""

    @options = options
