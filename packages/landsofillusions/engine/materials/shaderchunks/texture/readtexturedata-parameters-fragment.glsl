// LandsOfIllusions.Engine.Materials.readTextureDataParametersFragment
// IMPORTANT: To use this code the material needs to have derivatives enabled.

uniform bool powerOf2Texture;
uniform float mipmapBias;

#ifdef USE_NORMALMAP
  // Based on Normal Mapping Without Precomputed Tangents from http://www.thetenthplanet.de/archives/1180
  vec3 applyNormalMap(vec3 p, vec3 N, vec3 mapN) {
    vec3 dp1 = dFdx(p);
    vec3 dp2 = dFdy(p);
    vec2 duv1 = dFdx(vUv);
    vec2 duv2 = dFdy(vUv);

    // solve the linear system
    vec3 dp2perp = cross(dp2, N);
    vec3 dp1perp = cross(N, dp1);
    vec3 T = dp2perp * duv1.x + dp1perp * duv2.x;
    vec3 B = dp2perp * duv1.y + dp1perp * duv2.y;

    // construct a scale-invariant frame
    float invmax = inversesqrt(max(dot(T,T), dot(B,B)));
    mat3 TBN = mat3(T * invmax, B * invmax, N);

    return normalize(TBN * mapN);
  }
#endif
