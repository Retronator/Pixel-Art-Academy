// Artificial.Reality.Pages.Chemistry.Materials.Scattering.RaySplittingMaterial.fragment
precision highp float;
precision highp int;

#include <Artificial.Pyramid.Trigonometry>
#include <Artificial.Reality.Optics.FresnelEquations>
#include <Artificial.Reality.Pages.Chemistry.Materials.Scattering.uniforms>

uniform int updateLevel;
uniform sampler2D rayScatteringDataTexture;
uniform sampler2D surfaceSDFTexture;
uniform sampler2D rayPropertiesTexture;

varying vec2 vUv;

void main() {
  float rayColumn = vUv.x * raysCount;
  int rayIndex = int(rayColumn);

  float vertexRow = vUv.y * verticesPerRay;
  int vertexIndex = int(vertexRow);

  bool rightColumn = mod(rayColumn, 1.0) > 0.5;

  int vertexIndexToUpdateFrom = int(pow(2.0, float(updateLevel)));

  if (vertexIndex >= vertexIndexToUpdateFrom && rightColumn) {
    // Get parent segment position and direction.
    int parentVertexIndex = vertexIndex / 2;
    float parentV = (float(parentVertexIndex) + 0.5) / verticesPerRay;
    vec4 parentSegmentData = texture2D(rayScatteringDataTexture, vec2(vUv.x, parentV));
    vec4 parentVertexData = texture2D(rayScatteringDataTexture, vec2(vUv.x - 0.5 / raysCount, parentV));

    // Make sure that the vertex is alive.
    if (parentVertexData.a < 0.5) {
      // We don't need to split this segment.
      gl_FragColor = vec4(0.0);
      return;
    }

    vec2 parentPosition = parentVertexData.rg;
    vec2 parentDirection = parentSegmentData.rg;
    float parentTransmission = parentVertexData.b;

    // Determine if this segment is traveling inside or outside.
    bool parentSegmentOutside = texture2D(surfaceSDFTexture, parentPosition / canvasSize).a < 0.0;

    // Set complex refractive indices.
    vec2 materialProperties = texture2D(rayPropertiesTexture, vec2(vUv.x, 0.5)).rg;
    float refractiveIndex = materialProperties.r;
    float extinctionCoefficient = materialProperties.g;

    ComplexNumber n1 = ComplexNumber(1.0, 0.0);
    ComplexNumber n2 = ComplexNumber(1.0, 0.0);

    if (parentSegmentOutside) {
      // We're splitting a ray that is going into the material.
      n2.real = refractiveIndex;
      n2.imaginary = extinctionCoefficient;
    } else {
      // We're splitting a ray that is trying to go out of the material.
      n1.real = refractiveIndex;
      n1.imaginary = extinctionCoefficient;
    }

    // Determine surface normal.
    vec2 pixelUVSize = 1.0 / canvasSize;
    vec2 parentUV = parentPosition / canvasSize;

    float sdfUp = texture2D(surfaceSDFTexture, vec2(parentUV.x, parentUV.y - pixelUVSize.y)).a;
    float sdfDown = texture2D(surfaceSDFTexture, vec2(parentUV.x, parentUV.y + pixelUVSize.y)).a;
    float sdfLeft = texture2D(surfaceSDFTexture, vec2(parentUV.x - pixelUVSize.x, parentUV.y)).a;
    float sdfRight = texture2D(surfaceSDFTexture, vec2(parentUV.x + pixelUVSize.x, parentUV.y)).a;
    vec2 normal = normalize(vec2(sdfRight - sdfLeft, sdfDown - sdfUp));

    // Calculate reflectance.
    float angleOfIncidence = acos(abs(dot(parentDirection, normal)));
    float reflectance = FresnelEquations_getReflectance(angleOfIncidence, n1, n2);

    // Calculate direction and transmission of split ray.
    vec2 direction;
    float transmission = parentTransmission;
    bool segmentIsReflected = mod(float(vertexIndex), 2.0) < 0.5;

    if (segmentIsReflected) {
      direction = reflect(parentDirection, normal);
      transmission *= reflectance;

    } else {
      vec2 refractionNormal = parentSegmentOutside ? normal : -normal;
      direction = refract(parentDirection, refractionNormal, n1.real / n2.real);
      transmission *= (1.0 - reflectance);
    }

    gl_FragColor = vec4(direction.x, direction.y, transmission, transmission < minTransmission ? 0.0 : 1.0);

  } else {
    // Copy data.
    gl_FragColor = texture2D(rayScatteringDataTexture, vUv);
  }
}
