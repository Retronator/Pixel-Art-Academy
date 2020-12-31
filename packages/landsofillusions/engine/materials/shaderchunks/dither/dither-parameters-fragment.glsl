// LandsOfIllusions.Engine.Materials.ditherParametersFragment

bool dither2levels(float amount) {
  if (amount < 0.25) return false;
  if (amount > 0.75) return true;

  int x = int(mod(gl_FragCoord.x, 2.0));
  int y = int(mod(gl_FragCoord.y, 2.0));

  return x==y;
}

bool dither4levels(float amount) {
  if (amount < 0.125) return false;
  if (amount > 0.875) return true;

  int x = int(mod(gl_FragCoord.x, 2.0));
  int y = int(mod(gl_FragCoord.y, 2.0));

  if (x==1 && y==1) return true;
  if (x==0 && y==0) return amount > 0.375;
  if (x==1 && y==0) return amount > 0.625;
  return false;
}
