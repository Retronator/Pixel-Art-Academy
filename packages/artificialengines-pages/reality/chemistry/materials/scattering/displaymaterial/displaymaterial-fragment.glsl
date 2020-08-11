// Artificial.Reality.Pages.Chemistry.Materials.Scattering.DisplayMaterial.fragment
precision highp float;

#include <encodings_pars_fragment>
#include <tonemapping_pars_fragment>
#include <Artificial.Reality.Pages.Chemistry.Materials.Scattering.uniforms>

uniform sampler2D surfaceSDFTexture;
uniform sampler2D rayScatteringDataTexture;
uniform sampler2D lightTexture;
uniform bool schematicView;

varying vec2 vUv;

void main() {
  // Draw light with tone mapping.
  vec3 light = texture2D(lightTexture, vUv).rgb;
  vec3 toneMappedLight = OptimizedCineonToneMapping(light);

  // Convert from linear RGB to sRGB, since we're using linear tone mapping.
  // gl_FragColor = LinearTosRGB(vec4(toneMappedLight, 1.0));

  if (schematicView) {
    gl_FragColor = vec4(vec3(1.0) - toneMappedLight, 1.0);

  } else {
    gl_FragColor = vec4(toneMappedLight, 1.0);
  }

  // Draw surface edges.
  float sdf = texture2D(surfaceSDFTexture, vUv).a;
  bool insideSurface = sdf < 0.0;

  if (insideSurface) {
    if (schematicView) {
      gl_FragColor.rgb -= vec3(0.1);

    } else {
      gl_FragColor.rgb += vec3(0.1);
    }

    vec2 pixelUVSize = 1.0 / canvasSize;
    bool outsideUp = texture2D(surfaceSDFTexture, vec2(vUv.x, vUv.y - pixelUVSize.y)).a > 0.0;
    bool outsideDown = texture2D(surfaceSDFTexture, vec2(vUv.x, vUv.y + pixelUVSize.y)).a > 0.0;
    bool outsideLeft = texture2D(surfaceSDFTexture, vec2(vUv.x - pixelUVSize.x, vUv.y)).a > 0.0;
    bool outsideRight = texture2D(surfaceSDFTexture, vec2(vUv.x + pixelUVSize.x, vUv.y)).a > 0.0;

    if (outsideUp || outsideDown || outsideLeft || outsideRight) {
      if (schematicView) {
        gl_FragColor.rgb -= vec3(0.4);

      } else {
        gl_FragColor.rgb += vec3(0.3);
      }
    }
  }

  //vec4 rayScatteringData = texture2D(rayScatteringDataTexture, vUv);
  //gl_FragColor = rayScatteringData;
}
