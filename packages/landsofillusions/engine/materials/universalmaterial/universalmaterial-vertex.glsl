// LandsOfIllusions.Engine.Materials.UniversalMaterial.vertex
#include <THREE>

// Globals
uniform mat4 cameraAngleMatrix;

// Shading
#include <shadowmap_pars_vertex>

varying vec3 vNormal;
varying vec3 vViewPosition;

// Texture
#ifdef USE_MAP
  #include <uv_pars_vertex>

  uniform mat3 textureMapping;
#endif

// Material properties
#include <LandsOfIllusions.Engine.Materials.materialPropertiesParametersVertex>

// Lightmap area properties
#include <LandsOfIllusions.Engine.Materials.lightmapAreaPropertiesParametersVertex>

attribute vec2 lightmapCoordinates;

varying vec2 vLightmapCoordinates;
varying float vCameraAngleW;

void main()	{
  // Normals
  #include <beginnormal_vertex>
  #include <defaultnormal_vertex>
  vNormal = normalize(transformedNormal);

  // Position
  #include <begin_vertex>
  #include <project_vertex>
  #include <worldpos_vertex>

  // Shading
  #include <shadowmap_vertex>
  vViewPosition = -mvPosition.xyz;

  // Texture
  #include <LandsOfIllusions.Engine.Materials.mapTextureVertex>

  // Material properties
  #include <LandsOfIllusions.Engine.Materials.materialPropertiesVertex>

  // Lightmap area properties
  #include <LandsOfIllusions.Engine.Materials.lightmapAreaPropertiesVertex>

  // We need to linearly interpolate pixel coordinates in the picture's camera angle clip
  // space so we need to calculate the W component of the vertex in camera angle's space.
  vCameraAngleW = (cameraAngleMatrix * modelMatrix * vec4(position, 1.0)).w;
  vLightmapCoordinates = lightmapCoordinates * vCameraAngleW;
}
