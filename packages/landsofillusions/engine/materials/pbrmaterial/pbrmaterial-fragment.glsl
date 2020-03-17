// LandsOfIllusions.Engine.Materials.PBRMaterial.fragment
#include <THREE>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <normalmap_pars_fragment>
#include <packing>

#include <LandsOfIllusions.Engine.Materials.ditherParametersFragment>

// Globals
uniform vec2 renderSize;

// Cluster information
uniform vec2 clusterSize;
uniform mat4 clusterPlaneWorldMatrix;
uniform mat4 clusterPlaneWorldMatrixInverse;

// Texture
#include <LandsOfIllusions.Engine.Materials.readTextureDataParametersFragment>

// Radiance state
#include <LandsOfIllusions.Engine.RadianceState.commonParametersFragment>
uniform sampler2D radianceAtlasIn;
uniform sampler2D radianceAtlasOut;
uniform sampler2D probeMap;

varying vec2 vPixelCoordinates;
varying float vCameraAngleW;

varying vec3 vFragmentPositionInWorldSpace;

void main()	{
  // Find which radiance probe to use by sampling the probe map at pixel coordinates.
  vec2 pixelCoordinates = vPixelCoordinates / vCameraAngleW;
  pixelCoordinates = floor(pixelCoordinates + 0.5);

  float probeIndex = texture2D(probeMap, pixelCoordinates / clusterSize).a;
  vec2 probeCoordinates = vec2(
    mod(probeIndex, clusterSize.x),
    floor(probeIndex / clusterSize.x)
  );

  vec3 fragmentToViewDirectionInWorldSpace = normalize(cameraPosition - vFragmentPositionInWorldSpace);
  vec3 fragmentToViewDirectionInClusterSpace = transformDirection(fragmentToViewDirectionInWorldSpace, clusterPlaneWorldMatrixInverse);

  vec3 radiance = sampleRadiance(radianceAtlasOut, clusterSize, probeCoordinates, fragmentToViewDirectionInClusterSpace);

  // Color the pixel with the best match from the palette.
  gl_FragColor = vec4(radiance, 1);

  #include <tonemapping_fragment>
  #include <encodings_fragment>
}
