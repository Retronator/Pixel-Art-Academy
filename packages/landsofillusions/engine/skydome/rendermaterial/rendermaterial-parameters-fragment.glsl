// LandsOfIllusions.Engine.Skydome.RenderMaterial.parametersFragment
precision highp float;

#include <THREE>
#include <Artificial.Pyramid.OctahedronMap>

const int viewRaySteps = 64;

uniform float planetRadius;
uniform float planetRadiusSquared;

uniform float atmosphereBoundsHeight;
uniform float atmosphereBoundsRadiusSquared;
uniform float atmosphereScaleHeight;
uniform vec3 atmosphereRayleighCrossSection;
uniform float atmosphereMolecularNumberDensitySurface;

uniform vec3 starEmission;
uniform vec3 starDirection;
uniform float starAngularSizeHalf;

varying vec2 vUv;

float getLengthThroughAtmosphere(vec3 position, vec3 direction) {
  float extensionLength = dot(position, direction);
  float positionSquared = dot(position, position);
  float extensionHeightSquared = positionSquared - pow2(extensionLength);
  float fullLengthSquared = atmosphereBoundsRadiusSquared - extensionHeightSquared;
  return sqrt(fullLengthSquared) - extensionLength;
}

bool intersectsPlanet(vec3 position, vec3 direction) {
  float extensionLength = dot(position, direction);
  if (extensionLength >= 0.0) return false;
  float positionSquared = dot(position, position);
  float extensionHeightSquared = positionSquared - pow2(extensionLength);
  return extensionHeightSquared < planetRadiusSquared;
}
