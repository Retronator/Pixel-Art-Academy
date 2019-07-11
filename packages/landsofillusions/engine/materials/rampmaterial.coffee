LOI = LandsOfIllusions

class LOI.Engine.Materials.RampMaterial extends THREE.ShaderMaterial
  constructor: (options) ->
    paletteTexture = new LOI.Engine.Textures.Palette options.palette

    if options.texture
      if options.texture.spriteId
        # Find the sprite in cache or documents.
        sprite = LOI.Assets.Sprite.getFromCache options.texture.spriteId

        unless sprite
          sprite = LOI.Assets.Sprite.documents.findOne options.texture.spriteId

        if sprite
          # Create the sprite textures.
          spriteTextures = new LOI.Engine.Textures.Sprite sprite, options.texture

      else if options.texture.spriteName
        spriteTextures = new LOI.Engine.Textures.Mip options.texture.spriteName, options.texture

      # Create texture mapping matrix.
      elements = [1, 0, 0, 0, 1, 0, 0, 0, 1]

      if options.texture.mappingMatrix
        elements = _.defaults [], options.texture.mappingMatrix, elements

      textureMapping = new THREE.Matrix3().set elements...

      # Apply mapping offset.
      offsetMatrix = new THREE.Matrix3()
      offsetMatrix.elements[6] = options.texture.mappingOffset?.x or 0
      offsetMatrix.elements[7] = options.texture.mappingOffset?.y or 0

      textureMapping.multiply offsetMatrix

    super
      lights: true
      shadowSide: THREE.FrontSide

      uniforms: _.extend
        palette:
          value: paletteTexture
        map:
          value: spriteTextures?.paletteColorTexture
        normalMap:
          value: spriteTextures?.normalTexture
        normalScale:
          value: new THREE.Vector2 1, 1
        textureMapping:
          value: textureMapping
        ramp:
          value: options.paletteColor?.ramp
        shade:
          value: options.paletteColor?.shade
        smoothShading:
          value: options.smoothShading
        powerOf2Texture:
          value: spriteTextures?.isPowerOf2
        mipmapBias:
          value: options.texture?.mipmapBias or 0
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

  #ifdef USE_MAP
    // Map the texture from position to UV coordinates.
    vUv = (textureMapping * position).xy;
  #endif

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

uniform sampler2D palette;
uniform float ramp;
uniform float shade;
uniform bool smoothShading;
uniform bool powerOf2Texture;
uniform float mipmapBias;

#{LOI.Engine.Materials.ShaderChunks.readSpriteDataParameters}

varying vec3 vNormal;

void main()	{
  // Prepare normal.
  #include <normal_fragment_begin>

  // Determine palette color (ramp and shade).
  #ifdef USE_MAP
    #{LOI.Engine.Materials.ShaderChunks.readSpriteData}

  #else
    // We're using constants, read from uniforms.
    vec2 paletteColor = vec2((ramp + 0.5) / 256.0, (shade + 0.5) / 256.0);

  #endif

  #{LOI.Engine.Materials.ShaderChunks.readSourceColorFromPalette}

  // Shade from ambient to full light based on intensity.
  #{LOI.Engine.Materials.ShaderChunks.totalLightIntensity}
  float shadeFactor = mix(ambientLightColor.r, 1.0, totalLightIntensity);

  // Dim the color of the cluster by the shade factor.
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
  gl_FragColor = vec4(destinationColor, 1);
}
"""

    if @uniforms.map.value
      # Maps need to be set on the object itself as well for shader defines to kick in.
      @map = @uniforms.map.value
      @normalMap = @uniforms.normalMap.value

    @options = options
