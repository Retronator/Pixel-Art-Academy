// LandsOfIllusions.Engine.Materials.readTextureDataParametersFragment

uniform bool powerOf2Texture;
uniform float mipmapBias;

#ifdef USE_NORMALMAP
  #extension GL_OES_standard_derivatives : enable

  // Based on perturbNormal2Arb from https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/normalmap_pars_fragment.glsl.js#L16
  vec3 applyNormalMap(vec3 eye_pos, vec3 surf_norm, vec3 mapN) {
    vec3 q0 = vec3(dFdx(eye_pos.x), dFdx(eye_pos.y), dFdx(eye_pos.z));
    vec3 q1 = vec3(dFdy(eye_pos.x), dFdy(eye_pos.y), dFdy(eye_pos.z));
    vec2 st0 = dFdx(vUv.st);
    vec2 st1 = dFdy(vUv.st);

    float scale = sign(st1.t * st0.s - st0.t * st1.s);

    vec3 S = normalize((q0 * st1.t - q1 * st0.t) * scale);
    vec3 T = normalize((- q0 * st1.s + q1 * st0.s) * scale);
    vec3 N = normalize(surf_norm);
    mat3 tsn = mat3(S, T, N);

    mapN.xy *= normalScale;
    mapN.xy *= (float(gl_FrontFacing) * 2.0 - 1.0);

    return normalize(tsn * mapN);
  }
#endif
