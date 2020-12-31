// Artificial.Reality.Optics.Scattering
#ifndef ARTIFICIAL_REALITY_OPTICS_SCATTERING
#define ARTIFICIAL_REALITY_OPTICS_SCATTERING

const float Scattering_rayleighPhaseNormalizationFactor = 0.05968310366; // 3 / (16 * pi)

float Scattering_getRayleighPhase(float scatteringAngle) {
  return Scattering_rayleighPhaseNormalizationFactor * (1.0 + pow2(cos(scatteringAngle)));
}

const float Scattering_miePhaseNormalizationFactor = 0.1193662073; // 3 / (8 * pi)

float Scattering_getMiePhase(float scatteringAngle, float asymmetry) {
  float mu = cos(scatteringAngle);
  float mu2 = pow2(mu);
  float g = asymmetry;
  float g2 = pow2(g);
  return Scattering_miePhaseNormalizationFactor * (1.0 - g2) * (1.0 + mu2) / ((2.0 + g2) * pow(1.0 + g2 - 2.0 * g * mu, 1.5));
}

#endif
