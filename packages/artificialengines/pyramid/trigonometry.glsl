// Artificial.Pyramid.Trigonometry
#ifndef ARTIFICIAL_PYRAMID_TRIGONOMETRY
#define ARTIFICIAL_PYRAMID_TRIGONOMETRY

float sinh(float a) {
  float expA = exp(a);
  return (expA - 1.0 / expA) / 2.0;
}

float cosh(float a) {
  float expA = exp(a);
  return (expA + 1.0 / expA) / 2.0;
}

float tanh(float a) {
  float expA = exp(a);
  return (expA - 1.0 / expA) / (expA + 1.0 / expA);
}

#endif
