// LandsOfIllusions.Engine.Lightmap.UpdateMaterial.fragment
precision highp float;

layout(location = 0) out highp vec4 fragColor;

in vec3 irradiance;

void main() {
  fragColor = vec4(irradiance, 1.0);
}
