// Artificial.Reality.Optics.FresnelEquations
#ifndef ARTIFICIAL_REALITY_OPTICS_FRESNELEQUATIONS
#define ARTIFICIAL_REALITY_OPTICS_FRESNELEQUATIONS

#include <Artificial.Pyramid.ComplexNumber>
#include <Artificial.Reality.Optics.SnellsLaw>

// Reflectance

float FresnelEquations_getReflectance(const float angleOfIncidence, const ComplexNumber n1, const ComplexNumber n2) {
  ComplexNumber angleOfRefraction = SnellsLaw_getAngleOfRefraction(angleOfIncidence, n1, n2);
  ComplexNumber cosI = cos(ComplexNumber(angleOfIncidence, 0.0));
  ComplexNumber cosJ = cos(angleOfRefraction);

  ComplexNumber n1cosI = multiply(n1, cosI);
  ComplexNumber n2cosJ = multiply(n2, cosJ);
  ComplexNumber n1cosJ = multiply(n1, cosJ);
  ComplexNumber n2cosI = multiply(n2, cosI);

  float reflectanceS = pow2(abs(divide(subtract(n1cosI, n2cosJ), add(n1cosI, n2cosJ))));
  float reflectanceP = pow2(abs(divide(subtract(n1cosJ, n2cosI), add(n1cosJ, n2cosI))));

  return (reflectanceS + reflectanceP) / 2.0;
}

float FresnelEquations_getReflectance(const float angleOfIncidence, const float refractiveIndex1, const float refractiveIndex2, const float extinctionCoefficient1, const float extinctionCoefficient2) {
  ComplexNumber n1 = ComplexNumber(refractiveIndex1, extinctionCoefficient1);
  ComplexNumber n2 = ComplexNumber(refractiveIndex2, extinctionCoefficient2);

  return FresnelEquations_getReflectance(angleOfIncidence, n1, n2);
}

vec3 FresnelEquations_getReflectance(const float angleOfIncidence, const vec3 refractiveIndex1, const vec3 refractiveIndex2, const vec3 extinctionCoefficient1, const vec3 extinctionCoefficient2) {
  return vec3(
    FresnelEquations_getReflectance(angleOfIncidence, ComplexNumber(refractiveIndex1.r, extinctionCoefficient1.r), ComplexNumber(refractiveIndex2.r, extinctionCoefficient2.r)),
    FresnelEquations_getReflectance(angleOfIncidence, ComplexNumber(refractiveIndex1.g, extinctionCoefficient1.g), ComplexNumber(refractiveIndex2.g, extinctionCoefficient2.g)),
    FresnelEquations_getReflectance(angleOfIncidence, ComplexNumber(refractiveIndex1.b, extinctionCoefficient1.b), ComplexNumber(refractiveIndex2.b, extinctionCoefficient2.b))
  );
}

// Absorptance

float FresnelEquations_getAbsorptance(const float angleOfIncidence, const ComplexNumber n1, const ComplexNumber n2) {
  ComplexNumber angleOfRefraction = SnellsLaw_getAngleOfRefraction(angleOfIncidence, n1, n2);
  ComplexNumber cosI = cos(ComplexNumber(angleOfIncidence, 0.0));
  ComplexNumber cosJ = cos(angleOfRefraction);

  ComplexNumber n1cosI = multiply(n1, cosI);
  ComplexNumber n2cosJ = multiply(n2, cosJ);
  ComplexNumber n1cosJ = multiply(n1, cosJ);
  ComplexNumber n2cosI = multiply(n2, cosI);
  ComplexNumber n1cosI2 = multiply(2.0, n1cosI);

  float scalar = divide(n2cosJ, n1cosI).real;
  float absorptanceS = scalar * pow2(abs(divide(n1cosI2, add(n1cosI, n2cosJ))));
  float absorptanceP = scalar * pow2(abs(divide(n1cosI2, add(n2cosI, n1cosJ))));

  return (absorptanceS + absorptanceP) / 2.0;
}

float FresnelEquations_getAbsorptance(const float angleOfIncidence, const float refractiveIndex1, const float refractiveIndex2, const float extinctionCoefficient1, const float extinctionCoefficient2) {
  ComplexNumber n1 = ComplexNumber(refractiveIndex1, extinctionCoefficient1);
  ComplexNumber n2 = ComplexNumber(refractiveIndex2, extinctionCoefficient2);

  return FresnelEquations_getAbsorptance(angleOfIncidence, n1, n2);
}

vec3 FresnelEquations_getAbsorptance(const float angleOfIncidence, const vec3 refractiveIndex1, const vec3 refractiveIndex2, const vec3 extinctionCoefficient1, const vec3 extinctionCoefficient2) {
  return vec3(
    FresnelEquations_getAbsorptance(angleOfIncidence, ComplexNumber(refractiveIndex1.r, extinctionCoefficient1.r), ComplexNumber(refractiveIndex2.r, extinctionCoefficient2.r)),
    FresnelEquations_getAbsorptance(angleOfIncidence, ComplexNumber(refractiveIndex1.g, extinctionCoefficient1.g), ComplexNumber(refractiveIndex2.g, extinctionCoefficient2.g)),
    FresnelEquations_getAbsorptance(angleOfIncidence, ComplexNumber(refractiveIndex1.b, extinctionCoefficient1.b), ComplexNumber(refractiveIndex2.b, extinctionCoefficient2.b))
  );
}

// Both

void FresnelEquations_getReflectanceAndAbsorptance(const float angleOfIncidence, const ComplexNumber n1, const ComplexNumber n2, out float reflectance, out float absorptance) {
  ComplexNumber angleOfRefraction = SnellsLaw_getAngleOfRefraction(angleOfIncidence, n1, n2);
  ComplexNumber cosI = cos(ComplexNumber(angleOfIncidence, 0.0));
  ComplexNumber cosJ = cos(angleOfRefraction);

  ComplexNumber n1cosI = multiply(n1, cosI);
  ComplexNumber n2cosJ = multiply(n2, cosJ);
  ComplexNumber n1cosJ = multiply(n1, cosJ);
  ComplexNumber n2cosI = multiply(n2, cosI);

  ComplexNumber n1cosIPlusN2cosJ = add(n1cosI, n2cosJ);
  ComplexNumber n1cosJPlusN2cosI = add(n1cosJ, n2cosI);
  ComplexNumber n1cosI2 = multiply(2.0, n1cosI);

  float reflectanceS = pow2(abs(divide(subtract(n1cosI, n2cosJ), n1cosIPlusN2cosJ)));
  float reflectanceP = pow2(abs(divide(subtract(n1cosJ, n2cosI), n1cosJPlusN2cosI)));

  reflectance = (reflectanceS + reflectanceP) / 2.0;

  float scalar = divide(n2cosJ, n1cosI).real;
  float absorptanceS = scalar * pow2(abs(divide(n1cosI2, n1cosIPlusN2cosJ)));
  float absorptanceP = scalar * pow2(abs(divide(n1cosI2, n1cosJPlusN2cosI)));

  absorptance = (absorptanceS + absorptanceP) / 2.0;
}

void FresnelEquations_getReflectanceAndAbsorptance(const float angleOfIncidence, const float refractiveIndex1, const float refractiveIndex2, const float extinctionCoefficient1, const float extinctionCoefficient2, out float reflectance, out float absorptance) {
  ComplexNumber n1 = ComplexNumber(refractiveIndex1, extinctionCoefficient1);
  ComplexNumber n2 = ComplexNumber(refractiveIndex2, extinctionCoefficient2);

  FresnelEquations_getReflectanceAndAbsorptance(angleOfIncidence, n1, n2, reflectance, absorptance);
}

void FresnelEquations_getReflectanceAndAbsorptance(const float angleOfIncidence, const vec3 refractiveIndex1, const vec3 refractiveIndex2, const vec3 extinctionCoefficient1, const vec3 extinctionCoefficient2, out vec3 reflectance, out vec3 absorptance) {
  FresnelEquations_getReflectanceAndAbsorptance(angleOfIncidence, ComplexNumber(refractiveIndex1.r, extinctionCoefficient1.r), ComplexNumber(refractiveIndex2.r, extinctionCoefficient2.r), reflectance.r, absorptance.r),
  FresnelEquations_getReflectanceAndAbsorptance(angleOfIncidence, ComplexNumber(refractiveIndex1.g, extinctionCoefficient1.g), ComplexNumber(refractiveIndex2.g, extinctionCoefficient2.g), reflectance.g, absorptance.g),
  FresnelEquations_getReflectanceAndAbsorptance(angleOfIncidence, ComplexNumber(refractiveIndex1.b, extinctionCoefficient1.b), ComplexNumber(refractiveIndex2.b, extinctionCoefficient2.b), reflectance.b, absorptance.b);
}

#endif
