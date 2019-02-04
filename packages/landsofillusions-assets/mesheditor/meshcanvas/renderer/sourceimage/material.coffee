LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas.Renderer.SourceImage.Material extends THREE.ShaderMaterial
  constructor: (@sourceImage) ->
    paletteTextureData = new Uint8Array 256 * 256 * 4
    paletteTexture = new THREE.DataTexture paletteTextureData, 256, 256, THREE.RGBAFormat

    super
      transparent: true
      lights: true
      side: THREE.DoubleSide
      shadowSide: THREE.DoubleSide
      depthWrite: false

      uniforms: _.extend
        palette:
          value: null
        map:
          value: null
        normalMap:
          value: null
      ,
        THREE.UniformsLib.lights

      vertexShader: """
#include <common>
#include <uv_pars_vertex>

void main()	{
  // Transform position.
  vec4 worldPosition = modelMatrix * vec4(position, 1.0);
  gl_Position = projectionMatrix * viewMatrix * worldPosition;

  // Send through UV coordinates.
  vUv = uv;
}
"""

      fragmentShader: """
#include <common>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <normalmap_pars_fragment>
#include <packing>
#include <lights_pars_begin>

uniform mat4 modelViewMatrix;
uniform sampler2D palette;

void main()	{
  vec4 rampShadeDitherAlpha = texture2D(map, vUv);
  vec3 sourceColor = texture2D(palette, rampShadeDitherAlpha.xy).rgb;

  vec3 normal = texture2D(normalMap, vUv).xyz;
  normal = (normal - 0.5) * 2.0;

  // Accumulate directional lights.
  float totalLightIntensity = 0.0;

  DirectionalLight directionalLight;
  float lightIntensity;

  for (int i = 0; i < NUM_DIR_LIGHTS; i++) {
    directionalLight = directionalLights[i];

    // Shade using Lambert cosine law.
    lightIntensity = saturate(dot(directionalLight.direction, normal));

    // Add to total intensity.
    totalLightIntensity += lightIntensity;
  }

  // Shade from ambient to full light based on intensity.
  float shadeFactor = mix(ambientLightColor.r, 1.0, totalLightIntensity);

  // Dim the color of the cluster by the shade factor.
  vec3 shadedColor = sourceColor * shadeFactor;

  // Find the nearest color from the palette to represent the shaded color.
  vec2 shadeUv = rampShadeDitherAlpha.xy;
  vec3 bestColor;
  vec3 secondBestColor;
  float bestColorDistance = 1000000.0;
  float secondBestColorDistance = 1000000.0;

  for (int shadeIndex = 0; shadeIndex < 255; shadeIndex++) {
    shadeUv.y = float(shadeIndex) / 255.0;
    vec4 shadeEntry = texture2D(palette, shadeUv);
    //if (shadeEntry.a == 0.0) break;
    vec3 shade = shadeEntry.rgb;

    // Measure distance to color.
    float distance = distance(shade, shadedColor);

    if (distance < bestColorDistance) {
      secondBestColor = bestColor;
      secondBestColorDistance = bestColorDistance;
      bestColor = shade;
      bestColorDistance = distance;
    } else if (distance < secondBestColorDistance) {
      secondBestColor = shade;
      secondBestColorDistance = distance;
    }
  }

  vec3 destinationColor = bestColor;

  // Apply dithering.
  float ditherPercentage = 2.0 * bestColorDistance / (bestColorDistance + secondBestColorDistance);

  int x = int(mod(gl_FragCoord.x, 2.0));
  int y = int(mod(gl_FragCoord.y, 2.0));

  if (ditherPercentage > 1.0 - rampShadeDitherAlpha.b) {
    if (x==y) {
      destinationColor = secondBestColor;
    }
  } //else {
    // Apply smooth shading.
    //float blendFactor = bestColorDistance / (bestColorDistance + secondBestColorDistance);
    //destinationColor = mix(bestColor, secondBestColor, blendFactor);
  //}

  // Color the pixel with the best match from the palette.
  gl_FragColor = vec4(destinationColor, rampShadeDitherAlpha.a);

  if (rampShadeDitherAlpha.a < 0.5) discard;
}
"""
    @texturesDepenency = new Tracker.Dependency
    meshCanvas = @sourceImage.renderer.meshCanvas

    # Automatically update the palette texture.
    meshCanvas.autorun =>
      return unless palette = meshCanvas.meshLoader()?.palette()

      paletteTextureData.fill 0

      for ramp, rampIndex in palette.ramps
        for shade, shadeIndex in ramp.shades
          dataIndex = (rampIndex + shadeIndex * 256) * 4

          paletteTextureData[dataIndex] = shade.r * 255
          paletteTextureData[dataIndex + 1] = shade.g * 255
          paletteTextureData[dataIndex + 2] = shade.b * 255
          paletteTextureData[dataIndex + 3] = 255

      paletteTexture.needsUpdate = true

      @uniforms.palette.value = paletteTexture
      @needsUpdate = true

    # Automatically update the color texture.
    meshCanvas.autorun =>
      return unless picture = meshCanvas.activePicture()
      return unless paletteColorMap = picture.maps.paletteColor
      return unless bounds = picture.bounds()

      textureData = new Uint8Array bounds.width * bounds.height * 4

      for y in [0...bounds.height]
        for x in [0...bounds.width]
          continue unless picture.pixelExistsRelative x, y

          dataIndex = (x + y * bounds.width) * 4
          mapIndex = paletteColorMap.calculateDataIndex x, y

          textureData[dataIndex] = paletteColorMap.data[mapIndex]
          textureData[dataIndex + 1] = paletteColorMap.data[mapIndex + 1]
          textureData[dataIndex + 2] = 0 # TODO: Add dithering support.
          textureData[dataIndex + 3] = 255

      @map = new THREE.DataTexture textureData, bounds.width, bounds.height, THREE.RGBAFormat
      @map.needsUpdate = true
      @uniforms.map.value = @map
      @needsUpdate = true

      @texturesDepenency.changed()

    # Automatically update the normal texture.
    meshCanvas.autorun =>
      return unless picture = meshCanvas.activePicture()
      return unless normalMap = picture.maps.normal
      return unless bounds = picture.bounds()

      textureData = new Uint8Array bounds.width * bounds.height * 3

      for y in [0...bounds.height]
        for x in [0...bounds.width]
          dataIndex = (x + y * bounds.width) * 3
          normalMapIndex = normalMap.calculateDataIndex x, y

          textureData[dataIndex] = normalMap.signedData[normalMapIndex] + 127
          textureData[dataIndex + 1] = normalMap.signedData[normalMapIndex + 1] + 127
          textureData[dataIndex + 2] = normalMap.signedData[normalMapIndex + 2] + 127

      @normalMap = new THREE.DataTexture textureData, bounds.width, bounds.height, THREE.RGBFormat
      @normalMap.needsUpdate = true
      @uniforms.normalMap.value = @normalMap
      @needsUpdate = true

      @texturesDepenency.changed()
