AS = Artificial.Spectrum

class AS.ShadowMapDebugMaterial extends THREE.ShaderMaterial
  constructor: ->
    super
      uniforms: _.extend
        uvTransform:
          value: new THREE.Matrix3().identity()
        map:
          value: null

      vertexShader: """
#include <shadowmap_pars_vertex>
#include <uv_pars_vertex>

void main()	{
	#include <uv_vertex>
  #include <begin_vertex>
	#include <project_vertex>
  #include <worldpos_vertex>
	#include <shadowmap_vertex>
}
"""

      fragmentShader: """
#include <common>
#include <packing>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <shadowmap_pars_fragment>

void main()	{
  vec4 texelColor = texture2D(map, vUv);
  texelColor = mapTexelToLinear(texelColor);
  float depth = 1.0 - unpackRGBAToDepth(texelColor);
  gl_FragColor = vec4(depth, depth, depth, 1);
}
"""
