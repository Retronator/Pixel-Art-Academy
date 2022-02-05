// Artificial.Pyramid.ComplexNumber
#ifndef ARTIFICIAL_PYRAMID_COMPLEXNUMBER
#define ARTIFICIAL_PYRAMID_COMPLEXNUMBER

struct ComplexNumber {
  float real;
  float imaginary;
};

float abs(const ComplexNumber a) {
  return sqrt(pow2(a.real) + pow2(a.imaginary));
}

float argument(const ComplexNumber a) {
  return atan(a.imaginary, a.real);
}

ComplexNumber add(const ComplexNumber a, const ComplexNumber b) {
  return ComplexNumber(a.real + b.real, a.imaginary + b.imaginary);
}

ComplexNumber add(const ComplexNumber a, const float b) {
  return ComplexNumber(a.real + b, a.imaginary);
}

ComplexNumber add(const float a, const ComplexNumber b) {
  return add(b, a);
}

ComplexNumber subtract(const ComplexNumber a, const ComplexNumber b) {
  return ComplexNumber(a.real - b.real, a.imaginary - b.imaginary);
}

ComplexNumber subtract(const ComplexNumber a, const float b) {
  return add(a, -b);
}

ComplexNumber subtract(const float a, const ComplexNumber b) {
  return subtract(ComplexNumber(a, 0.0), b);
}

ComplexNumber multiply(const ComplexNumber a, const ComplexNumber b) {
  return ComplexNumber(
    a.real * b.real - a.imaginary * b.imaginary,
    a.real * b.imaginary + a.imaginary * b.real
  );
}

ComplexNumber multiply(const ComplexNumber a, const float b) {
  return ComplexNumber(a.real * b, a.imaginary * b);
}

ComplexNumber multiply(const float a, const ComplexNumber b) {
  return multiply(b, a);
}

ComplexNumber divide(const ComplexNumber a, const ComplexNumber b) {
  float scalar = 1.0 / (pow2(b.real) + pow2(b.imaginary));
  return ComplexNumber(
    scalar * (a.real * b.real + a.imaginary * b.imaginary),
    scalar * (a.imaginary * b.real - a.real * b.imaginary)
  );
}

ComplexNumber divide(const ComplexNumber a, const float b) {
  return ComplexNumber(a.real / b, a.imaginary / b);
}

ComplexNumber divide(const float a, const ComplexNumber b) {
  return divide(ComplexNumber(a, 0.0), b);
}

ComplexNumber pow2(const ComplexNumber a) {
  return multiply(a, a);
}

ComplexNumber sqrt(const ComplexNumber a) {
  float absoluteValue = abs(a);
  float imaginarySign = a.imaginary >= 0.0 ? 1.0 : -1.0;

  return ComplexNumber(
    sqrt((absoluteValue + a.real) / 2.0),
    imaginarySign * abs(sqrt((absoluteValue - a.real) / 2.0))
  );
}

ComplexNumber complexLog(const ComplexNumber a) {
  return ComplexNumber(
    log(abs(a)),
    argument(a)
  );
}

ComplexNumber complexSin(const ComplexNumber a) {
  return ComplexNumber(
    sin(a.real) * cosh(a.imaginary),
    cos(a.real) * sinh(a.imaginary)
  );
}

ComplexNumber complexCos(const ComplexNumber a) {
  return ComplexNumber(
    cos(a.real) * cosh(a.imaginary),
    -sin(a.real) * sinh(a.imaginary)
  );
}

ComplexNumber complexAsin(const ComplexNumber a) {
  ComplexNumber i = ComplexNumber(0.0, 1.0);
  ComplexNumber minusI = ComplexNumber(0.0, -1.0);
  return multiply(minusI, complexLog(add(multiply(i, a), sqrt(subtract(1.0, pow2(a))))));
}

#endif
