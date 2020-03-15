// LandsOfIllusions.Engine.Materials.PBRMaterial.fragment

#include <THREE>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <normalmap_pars_fragment>
#include <packing>

#include <Artificial.Reality.Optics.FresnelEquations>

#include <LandsOfIllusions.Engine.Materials.ditherParametersFragment>

// Globals
uniform vec2 renderSize;

// Cluster information
uniform vec2 clusterSize;

// Material information
uniform vec3 refractiveIndex;
uniform vec3 extinctionCoefficient;
uniform vec3 emission;

// Texture
#include <LandsOfIllusions.Engine.Materials.readTextureDataParametersFragment>

varying vec3 vNormal;
varying vec3 vViewPosition;
varying vec2 vPixelCoordinates;

void main()	{
  // Prepare normal.
  #include <normal_fragment_begin>

  vec3 viewDirection = normalize(vViewPosition);
  float angleOfIncidence = acos(dot(normal, viewDirection));

  vec3 emmisivity = FresnelEquations_getAbsorptance(angleOfIncidence, vec3(1.0), refractiveIndex, vec3(0.0), extinctionCoefficient);
  vec3 sourceColor = emission * emmisivity;

  // TODO: Calculate the shaded color.
  vec3 shadedColor = sourceColor;
  vec3 destinationColor = shadedColor;

  // Color the pixel with the best match from the palette.
  gl_FragColor = vec4(saturate(destinationColor), 1);

  #include <tonemapping_fragment>
  #include <encodings_fragment>
}
