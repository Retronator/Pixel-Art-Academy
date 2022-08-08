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

    # Asset in the clipboard should be bigger than in the portfolio.
    if portfolioScale < 1
      # Scale up to 0.5 to show pixel perfect at least on retina screens.
      scale = 0.5

    else
      # 1 -> 2
      # 2 -> 3
      # 3 -> 4
      # 4 -> 5
      # 5 -> 6
      # 6 -> 8
      scale = Math.ceil portfolioScale * 1.2
  
    # Apply minimum and maximum scale if provided (it could be a non-integer).
    scale = Math.max scale, options.scaleLimits.min if options?.scaleLimits?.min
    scale = Math.min scale, options.scaleLimits.max if options?.scaleLimits?.max

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
