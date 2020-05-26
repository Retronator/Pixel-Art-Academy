// LandsOfIllusions.Engine.Materials.paletteParametersFragment

vec3 boundColorToPaletteRamp(vec3 color, float ramp, float dither, bool smoothShading) {
  // Find the nearest color from the palette to represent the shaded color.
  vec3 bestColor;
  float bestColorDistance;

  bool passedZero = false;
  vec3 earlierColor;
  vec3 laterColor;
  float blendFactor = 0.0;

  vec3 previousColor;
  float previousSignedDistance;

  vec2 paletteColor = vec2(ramp, 0);

  for (int shadeIndex = 0; shadeIndex < 255; shadeIndex++) {
    paletteColor.y = (float(shadeIndex) + 0.5) / 256.0;
    vec4 shadeEntry = texture2D(palette, paletteColor);
    vec3 shade = shadeEntry.rgb;

    // Measure distance to color.
    vec3 difference = shade - color;
    float signedDistance = difference.x + difference.y + difference.z;
    float distance = abs(difference.x) + abs(difference.y) + abs(difference.z);

    if (shadeIndex == 0) {
      // Set initial values in first loop iteration.
      bestColor = shade;
      bestColorDistance = distance;
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

  vec3 boundColor = bestColor;

  // Apply dithering.
  if (abs(0.5 - blendFactor) < dither / 2.0) {
    if (dither2levels(0.5)) {
      boundColor = earlierColor;
    } else {
      boundColor = laterColor;
    }
  } else if (smoothShading && passedZero) {
    boundColor = mix(earlierColor, laterColor, blendFactor);
  }

  return boundColor;
}
