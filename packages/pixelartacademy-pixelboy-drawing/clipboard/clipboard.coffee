AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Drawing.Clipboard extends AM.Component
  @register 'PixelArtAcademy.PixelBoy.Apps.Drawing.Clipboard'
  
  @calculateAssetSize: (portfolioScale, bounds, options) ->
    width = bounds?.width or 1
    height = bounds?.height or 1
    displayScale = LOI.adventure.interface.display.scale()

    if options?.pixelArtScaling
      # Asset in the clipboard should be bigger than in the portfolio.
      if portfolioScale < 1
        # The asset was scaled down in the portfolio, but we should remain at least pixel perfect in the clipboard.
        minimumScale = 1 / displayScale / window.devicePixelRatio
        scale = Math.max portfolioScale, minimumScale
  
      else
        # 1 -> 2
        # 2 -> 3
        # 3 -> 4
        # 4 -> 5
        # 5 -> 6
        # 6 -> 8
        scale = Math.ceil portfolioScale * 1.2
      
    else
      # Make the asset fit in the clipboard (200px).
      scale = _.min [1 / displayScale, 174 / width, 160 / height]

    # Apply minimum and maximum scale if provided (it could be a non-integer).
    scale = Math.max scale, options.scaleLimits.min if options?.scaleLimits?.min
    scale = Math.min scale, options.scaleLimits.max if options?.scaleLimits?.max

    contentWidth = width * scale
    contentHeight = height * scale

    borderWidth = if options.border then 7 else 0

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
