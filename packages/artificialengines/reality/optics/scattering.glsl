// Artificial.Reality.Optics.Scattering

const float Scattering_rayleighPhaseFunctionNormalizationFactor = 0.05968310366; // 3 / (16 * pi)

float Scattering_getRayleighPhaseFunction(float scatteringAngle) {
  return Scattering_rayleighPhaseFunctionNormalizationFactor * (1.0 + pow2(cos(scatteringAngle)));
}
