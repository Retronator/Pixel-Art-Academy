LOI = LandsOfIllusions
AB = Artificial.Base
AM = Artificial.Mummification

class LOI.Assets.ColorHelper
  # Return the color from the palette that exactly matches the given RGB color.
  @exactPaletteColorFromRGB: (palette, r, g, b) ->
    for ramp, rampIndex in palette.ramps
      for shade, shadeIndex in ramp.shades
        return {ramp: rampIndex, shade: shadeIndex} if shade.r is r and shade.g is g and shade.b is b
        
    null

  @exactPaletteColor: (palette, color) ->
    @exactPaletteColorFromRGB palette, color.r, color.g, color.b
  
  # Return the color from the palette closest to the given RGB color.
  # You can provide a background color and if the target color is closest to the
  # background color than any of the palette colors, the method will return null.
  @closestPaletteColorFromRGB: (palette, r, g, b, backgroundColor = null) ->
    closestRamp = null
    closestShade = null
    smallestColorDistance = if backgroundColor then @colorRGBDistance backgroundColor, r, g, b else 3
    
    for ramp, rampIndex in palette.ramps
      for shade, shadeIndex in ramp.shades
        distance = @colorRGBDistance shade, r, g, b
        
        if distance < smallestColorDistance
          smallestColorDistance = distance
          closestRamp = rampIndex
          closestShade = shadeIndex

    # Return nothing if the background color was closer to any of the palette colors.
    return null unless closestRamp?

    ramp: closestRamp
    shade: closestShade

  @closestPaletteColor: (palette, color, backgroundColor = null) ->
    @closestPaletteColorFromRGB palette, color.r, color.g, color.b, backgroundColor

  # Calculate the distance between two color objects.
  @colorDistance: (color1, color2) ->
    @RGBDistance color1.r, color1.g, color1.b, color2.r, color2.g, color2.b

  # Calculate the distance between a color object and RGB triplet.
  @colorRGBDistance: (color, r, g, b) ->
    @RGBDistance color.r, color.g, color.b, r, g, b
    
  # Calculate the distance between two RGB triplets.
  @RGBDistance: (r1, g1, b1, r2, g2, b2) ->
    Math.abs(r1 - r2) + Math.abs(g1 - g2) + Math.abs(b1 - b2)
    
  # Determine if two asset colors are equal.
  # You can provide a background color which can stand-in if any of the two colors are not provided.
  @areAssetColorsEqual: (assetColor1, assetColor2, palette, backgroundColor) ->
    # If both colors are absent, we have a match either way.
    return true unless assetColor1 or assetColor2
    
    # If we don't have both colors and there is no background, it's not a match.
    return false unless assetColor1 and assetColor2 or backgroundColor
    
    color1 = if assetColor1 then @resolveAssetColor assetColor1, palette else backgroundColor
    color2 = if assetColor2 then @resolveAssetColor assetColor2, palette else backgroundColor
    
    color1.r is color2.r and color1.g is color2.g and color1.b is color2.b
    
  @resolveAssetColor: (assetColor, palette) ->
    # The color can be specified directly as an RGB object.
    return assetColor.directColor if assetColor.directColor
    
    # The color can be indexing into a palette.
    if assetColor.paletteColor
      shades = palette.ramps[assetColor.paletteColor.ramp].shades
      shadeIndex = THREE.MathUtils.clamp assetColor.paletteColor.shade, 0, shades.length - 1
      return shades[shadeIndex]
      
    # Otherwise we assume the color has already been resolved to an RGB object.
    assetColor
    
  @getPaletteColorIndex: (assetColor, palette) ->
    return 0 unless assetColor.paletteColor
    
    index = 0
    index += palette.ramps[rampIndex].shades.length for rampIndex in [0...assetColor.paletteColor.ramp]
    index + assetColor.paletteColor.shade
