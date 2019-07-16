LOI = LandsOfIllusions

class LOI.Engine.Materials.RampMaterial extends LOI.Engine.Materials.Material
  @id: -> 'LandsOfIllusions.Engine.Materials.RampMaterial'
  @initialize()

  @createTextureMappingMatrices: (textureOptions) ->
    # Create the texture mapping matrix.
    elements = [1, 0, 0, 0, 1, 0, 0, 0, 1]

    if textureOptions.mappingMatrix
      elements = _.defaults [], textureOptions.mappingMatrix, elements

    mapping = new THREE.Matrix3().set elements...

    offset = new THREE.Matrix3()
    offset.elements[6] = textureOptions.mappingOffset?.x or 0
    offset.elements[7] = textureOptions.mappingOffset?.y or 0

    {mapping, offset}

  @getTransparentProperty: (options) ->
    # Note: We make dithered materials transparent too (even though this is not
    # required for rendering) so that they get properly hidden for opaque shadow map.
    options.translucency?.amount or options.translucency?.dither

  @getTextureUniforms: (options) ->
    textureMapping = LOI.Engine.Materials.RampMaterial.createTextureMappingMatrices options.texture if options.texture

    map:
      value: null
    powerOf2Texture:
      value: null
    textureMapping:
      value: textureMapping?.mapping
    uvTransform:
      value: textureMapping?.offset
    mipmapBias:
      value: options.texture?.mipmapBias or 0

  @updateTextures: (material) ->
    spriteTextures = LOI.Engine.Textures.getTextures material.options.texture

    Tracker.nonreactive =>
      Tracker.autorun =>
        spriteTextures.depend()

        material.uniforms.map.value = spriteTextures.paletteColorTexture
        material.uniforms.normalMap.value = spriteTextures.normalTexture if material.uniforms.normalMap
        material.uniforms.powerOf2Texture.value = spriteTextures.isPowerOf2

        # Maps need to be set on the object itself as well for shader defines to kick in.
        material.map = spriteTextures.paletteColorTexture
        material.normalMap = spriteTextures.normalTexture  if material.uniforms.normalMap

        material.needsUpdate = true
        material._dependency.changed()

  constructor: (options) ->
    paletteTexture = new LOI.Engine.Textures.Palette options.palette

    transparent = LOI.Engine.Materials.RampMaterial.getTransparentProperty options

    parameters =
      lights: true

      # Note: We need the transparent property to be a boolean since it's compared by equality against true/false.
      transparent: transparent > 0

      uniforms: _.extend
        # Globals
        renderSize:
          value: null

        # Color information
        ramp:
          value: options.ramp
        shade:
          value: options.shade
        dither:
          value: options.dither
        palette:
          value: paletteTexture

        # Shading
        smoothShading:
          value: options.smoothShading
        directionalShadowColorMap:
          value: []
        directionalOpaqueShadowMap:
          value: []
        preprocessingMap:
          value: null
      ,
        # Texture
        LOI.Engine.Materials.RampMaterial.getTextureUniforms options
      ,
        normalMap:
          value: null
        normalScale:
          value: new THREE.Vector2 1, 1

        # Translucency
        opacity:
          value: 1 - (options.translucency?.amount or 0)
        translucencyDither:
          value: options.translucency?.dither or 0
      ,
        THREE.UniformsLib.lights

      vertexShader: """
#include <common>
#include <shadowmap_pars_vertex>
#include <uv_pars_vertex>

varying vec3 vNormal;

#ifdef USE_MAP
  uniform mat3 textureMapping;
#endif

#ifdef USE_NORMALMAP
  varying vec3 vViewPosition;
#endif

void main()	{
  #include <beginnormal_vertex>
  #include <defaultnormal_vertex>
  vNormal = normalize(transformedNormal);

  #include <begin_vertex>
	#include <project_vertex>
  #include <worldpos_vertex>
	#include <shadowmap_vertex>

  #{LOI.Engine.Materials.ShaderChunks.mapTextureVertex}

  #ifdef USE_NORMALMAP
    vViewPosition = - mvPosition.xyz;
  #endif
}
"""

      fragmentShader: """
#include <common>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <normalmap_pars_fragment>
#include <packing>
#include <lights_pars_begin>
#include <shadowmap_pars_fragment>

#{LOI.Engine.Materials.ShaderChunks.ditherParametersFragment}

// Globals
uniform vec2 renderSize;

// Color information
uniform float ramp;
uniform float shade;
uniform float dither;
uniform sampler2D palette;

// Shading
uniform bool smoothShading;
#{LOI.Engine.Materials.ShaderChunks.totalLightIntensityParametersFragment}
uniform sampler2D preprocessingMap;

// Texture
#{LOI.Engine.Materials.ShaderChunks.readTextureDataParametersFragment}

// Translucency
uniform float opacity;
uniform float translucencyDither;

varying vec3 vNormal;

void main()	{
  // Apply translucency dither first since that can discard the whole fragment altogether.
  if (dither4levels(translucencyDither)) discard;

  // Prepare normal.
  #include <normal_fragment_begin>

  // Determine palette color (ramp and shade).
  vec2 paletteColor;

  #ifdef USE_MAP
    #{LOI.Engine.Materials.ShaderChunks.readTextureDataFragment}

  #else
    // We're using constants, read from uniforms.
    #{LOI.Engine.Materials.ShaderChunks.setPaletteColorFromUniformsFragment}

  #endif

  // Calculate total light intensity. This step also tints the palette color based
  // on shadow color, so we have to do it before applying tinting in preprocessing.
  #{LOI.Engine.Materials.ShaderChunks.totalLightIntensityFragment}

  // Apply preprocessing info. The parameters are:
  // r: tint ramp
  // g: tint shade
  vec2 normalizedCoordinates = gl_FragCoord.xy / renderSize;
  vec4 preprocessingInfo = texture2D(preprocessingMap, normalizedCoordinates);

  // Tint the color if needed.
  if (preprocessingInfo.r < 1.0) {
    paletteColor.r = (preprocessingInfo.r * 255.0 + 0.5) / 256.0;
  }

  // Get actual RGB values for this palette color.
  #{LOI.Engine.Materials.ShaderChunks.readSourceColorFromPaletteFragment}

  // Shade from ambient to full light based on intensity.
  float shadeFactor = mix(ambientLightColor.r, 1.0, totalLightIntensity);
  vec3 shadedColor = sourceColor * shadeFactor;

  // Find the nearest color from the palette to represent the shaded color.
  vec3 bestColor;
  float bestColorDistance;

  bool passedZero = false;
  vec3 earlierColor;
  vec3 laterColor;
  float blendFactor;

  vec3 previousColor;
  float previousSignedDistance;

  for (int shadeIndex = 0; shadeIndex < 255; shadeIndex++) {
    paletteColor.y = (float(shadeIndex) + 0.5) / 256.0;
    vec4 shadeEntry = texture2D(palette, paletteColor);
    vec3 shade = shadeEntry.rgb;

    // Measure distance to color.
    vec3 difference = shade - shadedColor;
    float signedDistance = difference.x + difference.y + difference.z;
    float distance = abs(difference.x) + abs(difference.y) + abs(difference.z);

    if (shadeIndex == 0) {
      // Set initial values in first loop iteration.
      bestColor = shade;
      bestColorDistance = distance;
    } else {
      // See if we've crossed zero distance, which means our target shaded color is between the previous and current shade.
      if (previousSignedDistance < 0.0 && signedDistance >= 0.0 || previousSignedDistance >= 0.0 && signedDistance < 0.0) {
        passedZero = true;
        earlierColor = previousColor;
        laterColor = shade;
        blendFactor = abs(previousSignedDistance) / abs(signedDistance - previousSignedDistance);
      }

      if (distance < bestColorDistance) {
        bestColor = shade;
        bestColorDistance = distance;

      // Note: We have to make sure the distance increased since there could be two of the same colors in the palette.
      } else if (distance > bestColorDistance) {
        // We have increased the distance, which means we're moving away from the best color and can safely quit.
        break;
      }
    }

    previousSignedDistance = signedDistance;
    previousColor = shade;
  }

  vec3 destinationColor = bestColor;

  if (smoothShading && passedZero) {
    destinationColor = mix(earlierColor, laterColor, blendFactor);
  }

  // Color the pixel with the best match from the palette.
  gl_FragColor = vec4(destinationColor, opacity);
}
"""
    blending = options.translucency?.blending

    if transparent and blending
      parameters.blending = THREE[blending.preset] if blending.preset?
      parameters.blendEquation = THREE[blending.equation] if blending.equation?
      parameters.blendSrc = THREE[blending.sourceFactor] if blending.sourceFactor?
      parameters.blendDst = THREE[blending.destinationFactor] if blending.destinationFactor?

    super parameters
    @options = options

    LOI.Engine.Materials.RampMaterial.updateTextures @ if @options.texture
