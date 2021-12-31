// LandsOfIllusions.Engine.Materials.GIMaterial.vertex
#include <THREE>

#ifdef USE_MAP
  #include <uv_pars_vertex>
#endif

// Globals
uniform mat4 cameraAngleMatrix;

attribute vec2 lightmapCoordinates;

varying vec2 vLightmapCoordinates;
varying float vCameraAngleW;

#ifdef USE_MAP
  uniform mat3 textureMapping;
#endif

#include <LandsOfIllusions.Engine.Materials.materialPropertiesParametersVertex>
#include <LandsOfIllusions.Engine.Materials.lightmapAreaPropertiesParametersVertex>

void main()	{
  #include <begin_vertex>
  #include <project_vertex>

  // We need to linearly interpolate pixel coordinates in the picture's camera angle clip
  // space so we need to calculate the W component of the vertex in camera angle's space.
  vCameraAngleW = (cameraAngleMatrix * modelMatrix * vec4(position, 1.0)).w;
  vLightmapCoordinates = lightmapCoordinates * vCameraAngleW;

  #include <LandsOfIllusions.Engine.Materials.mapTextureVertex>
  #include <LandsOfIllusions.Engine.Materials.materialPropertiesVertex>
  #include <LandsOfIllusions.Engine.Materials.lightmapAreaPropertiesVertex>
}
