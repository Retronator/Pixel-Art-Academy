LOI = LandsOfIllusions

class LOI.Engine.Materials.DepthMaterial extends LOI.Engine.Materials.Material
  @id: -> 'LandsOfIllusions.Engine.Materials.DepthMaterial'
  @initialize()

  constructor: (options) ->
    if options.texture
      spriteTextures = LOI.Engine.Textures.getTextures options.texture
      textureMapping = LOI.Engine.Materials.RampMaterial.createTextureMappingMatrices options.texture

    super
      uniforms: _.extend
        map:
          value: null
        textureMapping:
          value: textureMapping?.mapping
        uvTransform:
          value: textureMapping?.offset
        powerOf2Texture:
          value: null
        mipmapBias:
          value: options.texture?.mipmapBias or 0
        opacity:
          value: 1

      vertexShader: """
#include <common>
#include <uv_pars_vertex>

#ifdef USE_MAP
  uniform mat3 textureMapping;
#endif

void main()	{
  #include <begin_vertex>
	#include <project_vertex>
  #include <worldpos_vertex>

  #ifdef USE_MAP
    // Map the texture from position to UV coordinates.
    vec3 mappedPosition = textureMapping * position;

    // Set the z coordinate to 1 so we can apply the UV transform.
    mappedPosition.z = 1.0;
    vUv = (uvTransform * mappedPosition).xy;
  #endif
}
"""

      fragmentShader: """
#include <common>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <packing>

uniform bool powerOf2Texture;
uniform float mipmapBias;

void main()	{
  // Discard transparent pixels for textured fragments.
  #ifdef USE_MAP
    #{LOI.Engine.Materials.ShaderChunks.readSpriteData}
  #endif

  gl_FragColor = packDepthToRGBA(gl_FragCoord.z);
}
"""

    if spriteTextures
      Tracker.nonreactive =>
        Tracker.autorun =>
          spriteTextures.depend()

          @uniforms.map.value = spriteTextures.paletteColorTexture
          @uniforms.powerOf2Texture.value = spriteTextures.isPowerOf2

          # Map needs to be set on the object itself as well for shader defines to kick in.
          @map = spriteTextures.paletteColorTexture

          @needsUpdate = true
          @_dependency.changed()

    @options = options
