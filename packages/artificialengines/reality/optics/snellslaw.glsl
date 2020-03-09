// Artificial.Reality.Optics.SnellsLaw
#ifndef ARTIFICIAL_REALITY_OPTICS_SNELLSLAW
#define ARTIFICIAL_REALITY_OPTICS_SNELLSLAW

#include <Artificial.Pyramid.ComplexNumber>

float SnellsLaw_getAngleOfRefraction(const float angleOfIncidence, const float refractiveIndex1, const float refractiveIndex2) {
  return asin(refractiveIndex1 * sin(angleOfIncidence) / refractiveIndex2);
}

ComplexNumber SnellsLaw_getAngleOfRefraction(const float angleOfIncidence, const ComplexNumber refractiveIndex1, const ComplexNumber refractiveIndex2) {
  return asin(divide(multiply(refractiveIndex1, sin(angleOfIncidence)), refractiveIndex2));
}

#endif
