AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Drawing.Clipboard extends AM.Component
  @register 'PixelArtAcademy.PixelBoy.Apps.Drawing.Clipboard'
  
  @calculateAssetSize: (bounds, scaleLimits) ->
    width = bounds?.width or 1
    height = bounds?.height or 1

    # Scale the sprite as much as possible while remaining under 100px.
    maxSize = 100
    maxScale = scaleLimits?.max or 8

    size = Math.max width, height
    return 1 if _.isNaN size
    
    scale = 1
  
    if size > maxSize
      # Scale downwards until we're under max size (using scale as the denominator).
      scale++ while size / scale > maxSize
      return 1 / scale
  
    else
      # Scale upwards until you hit max scale or max size.
      scale++ while scale < maxScale and (scale + 1) * size < maxSize
  
    # Apply minimum and maximum scale if provided (it could be a non-integer).
    scale = Math.max scale, scaleLimits.min if scaleLimits?.min
    scale = Math.min scale, scaleLimits.max if scaleLimits?.max

    contentWidth = width * scale
    contentHeight = height * scale

    borderWidth = 7

    {contentWidth, contentHeight, borderWidth, scale}
  
  constructor: (@drawing) ->
    super arguments...

  asset: ->
    @drawing.portfolio().displayedAsset()?.asset

  onBackButton: ->
    # Relay to asset clipboard component.
    clipboardComponent = @drawing.portfolio().displayedAsset()?.asset.clipboardComponent
    result = clipboardComponent?.onBackButton?()
    return result if result?
