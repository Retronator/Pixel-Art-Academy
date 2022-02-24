// LandsOfIllusions.Engine.Lightmap.UpdateMaterial.fragment
precision highp float;

uniform float blendFactor;

layout(location = 0) out highp vec4 fragColor;

in vec3 irradiance;

void main() {
  // We premultiply the color with the alpha, so that we can use source * destination alpha in the blending equation.
  fragColor = vec4(irradiance * blendFactor, blendFactor);
}
