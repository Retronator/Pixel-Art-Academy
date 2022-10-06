LOI = LandsOfIllusions

class LOI.Assets.Bitmap.Attribute.Flags extends LOI.Assets.Bitmap.Attribute
  @id = LOI.Assets.Bitmap.Attribute.Ids.Flags
  @arrayClass = Uint8Array
  @elementsPerPixel = 1

  pixelHasFlag: (x, y, flagValue) ->
    @pixelHasFlagAtIndex @getPixelIndex(x, y), flagValue

  pixelHasFlagAtIndex: (index, flagValue) ->
    @array[index] & flagValue

  setPixelFlag: (x, y, flagValue) ->
    @setPixelFlagAtIndex @getPixelIndex(x, y), flagValue

  setPixelFlagAtIndex: (index, flagValue) ->
    @array[index] |= flagValue

  clearPixelFlag: (x, y, flagValue) ->
    @clearPixelFlagAtIndex @getPixelIndex(x, y), flagValue

  clearPixelFlagAtIndex: (index, flagValue) ->
    @array[index] &= ~flagValue
  
  pixelExists: (x, y) ->
    @pixelExistsAtIndex @getPixelIndex x, y

  pixelExistsAtIndex: (index) ->
    # Pixel exists if at least one flag is set.
    @array[index] > 0
    
  switchColorFlag: (x, y) ->
    @switchColorFlagAtIndex @getPixelIndex x, y
    
  switchColorFlagAtIndex: (index, newColorFlag) ->
    otherColorFlags = LOI.Assets.Bitmap.Attribute.allColorFlagsMask & ~newColorFlag
  
    @setPixelFlagAtIndex index, newColorFlag
    @clearPixelFlagAtIndex index, otherColorFlags
