// Artificial.Pyramid.IntegerOperations
#ifndef ARTIFICIAL_PYRAMID_INTEGEROPERATIONS
#define ARTIFICIAL_PYRAMID_INTEGEROPERATIONS

int mod(int a, int b) {
  int whole = a / b;
  return a - whole * b;
}

int sign(int a) {
  if (a > 0) return 1;
  if (a < 0) return -1;
  return 0;
}

int max(int a, int b) {
  if (a > b) return a;
  return b;
}

int min(int a, int b) {
  if (a < b) return a;
  return b;
}

int abs(int a) {
  if (a < 0) return -a;
  return a;
}

#endif
