// LandsOfIllusions.Engine.Materials.PBRMaterial.fragment
#include <THREE>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <normalmap_pars_fragment>

#include <Artificial.Pyramid.IntegerOperations>

// Globals
uniform vec2 renderSize;
uniform bool cameraParallelProjection;
uniform vec3 cameraDirection;

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

  // Note: We need to use integer arithmetics to avoid rounding errors when computing probe coordinates.
  int probeIndex = int(texture2D(probeMap, pixelCoordinates / clusterSize).a);
  int clusterWidth = int(clusterSize.x);
  vec2 probeCoordinates = vec2(
    mod(probeIndex, clusterWidth),
    probeIndex / clusterWidth
  );

  vec3 fragmentToViewDirectionInWorldSpace;

  if (cameraParallelProjection) {
    fragmentToViewDirectionInWorldSpace = -cameraDirection;

  } else {
    fragmentToViewDirectionInWorldSpace = normalize(cameraPosition - vFragmentPositionInWorldSpace);
  }

  vec3 fragmentToViewDirectionInClusterSpace = transformDirection(fragmentToViewDirectionInWorldSpace, clusterPlaneWorldMatrixInverse);

  vec3 radiance = sampleRadiance(radianceAtlasOut, clusterSize, probeCoordinates, fragmentToViewDirectionInClusterSpace);
  gl_FragColor = vec4(radiance, 1);
}
