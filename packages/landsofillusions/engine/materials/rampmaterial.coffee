LOI = LandsOfIllusions

class LOI.Engine.Materials.RampMaterial extends THREE.ShaderMaterial
  constructor: (options) ->
    shades = (THREE.Color.fromObject shade for shade in options.shades)

    super
      lights: true
      shadowSide: THREE.FrontSide

      uniforms: _.extend
        shades:
          type: 'c'
          value: shades
      ,
        THREE.UniformsLib.lights

      vertexShader: """
#include <shadowmap_pars_vertex>

varying vec3 vNormal;

void main()	{
  vNormal = normalize((modelViewMatrix * vec4(normal, 0.0)).xyz);

  #include <begin_vertex>
	#include <project_vertex>
  #include <worldpos_vertex>
	#include <shadowmap_vertex>
}
"""

      fragmentShader: """
#include <common>
#include <packing>
#include <lights_pars_begin>
#include <shadowmap_pars_fragment>

uniform vec3 shades[#{options.shades.length}];

varying vec3 vNormal;

void main()	{
  vec3 sourceColor = shades[#{options.shadeIndex}];

  #{LOI.Engine.Materials.ShaderChunks.totalLightIntensity}

  // Shade from ambient to full light based on intensity.
  float shadeFactor = mix(ambientLightColor.r, 1.0, totalLightIntensity);

  // Dim the color of the cluster by the shade factor.
  vec3 shadedColor = sourceColor * shadeFactor;

  // Find the nearest color from the palette to represent the shaded color.
  vec3 bestColor;
  vec3 secondBestColor;
  float bestColorDistance = 1000000.0;
  float secondBestColorDistance = 1000000.0;

  for (int shadeIndex = 0; shadeIndex < #{options.shades.length}; shadeIndex++) {
    vec3 shade = shades[shadeIndex];
    float distance = distance(shade, shadedColor);

    if (distance < bestColorDistance) {
      secondBestColor = bestColor;
      secondBestColorDistance = bestColorDistance;
      bestColor = shade;
      bestColorDistance = distance;
    } else if (distance < secondBestColorDistance) {
      secondBestColor = shade;
      secondBestColorDistance = distance;
    }
  }

  vec3 destinationColor = bestColor;

  /* Smooth shading routine
  float blendFactor = bestColorDistance / (bestColorDistance + secondBestColorDistance);
  vec3 destinationColor = mix(bestColor, secondBestColor, blendFactor);
  */

  // Color the pixel with the best match from the palette.
  gl_FragColor = vec4(destinationColor, 1);
}
"""

    @options = options
