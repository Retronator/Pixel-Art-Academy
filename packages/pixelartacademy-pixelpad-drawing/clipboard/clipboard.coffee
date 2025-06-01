AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.Clipboard extends LOI.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Clipboard'
  @register @id()
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    variables:
      open: AEc.ValueTypes.Trigger
      close: AEc.ValueTypes.Trigger
      secondPageOpen: AEc.ValueTypes.Trigger
      secondPageClose: AEc.ValueTypes.Trigger
    
  @calculateAssetSize: (portfolioScale, bounds, options) ->
    width = bounds?.width or 1
    height = bounds?.height or 1
    displayScale = LOI.adventure.interface.display.scale()
    fitScale = Math.min 174 / width, 160 / height

    # Apply minimum and maximum scale if provided (it could be a non-integer).
    fitScale = Math.max fitScale, options.scaleLimits.min if options?.scaleLimits?.min
    fitScale = Math.min fitScale, options.scaleLimits.max if options?.scaleLimits?.max
    
    if options?.pixelArtScaling
      if portfolioScale < 1
        # The asset was scaled down in the portfolio, so we will need to scale downwards. We start
        # operating in effective scale to still have integer magnification compared to window pixels.
        effectiveScale = displayScale
        effectiveScale-- while effectiveScale / displayScale > fitScale
      
        if effectiveScale > 0
          scale = effectiveScale / displayScale
        
        else
          # We need to reduce scale below 1 effective pixel so we start dividing by integer amounts below 1.
          divisor = 1
          divisor++ while 1 / divisor / displayScale > fitScale
          
          effectiveScale = 1 / divisor
    
          scale = Math.max portfolioScale, effectiveScale / displayScale
  
      else
        # Asset in the clipboard should be bigger than in the portfolio.
        # 1 -> 2
        # 2 -> 3
        # 3 -> 4
        # 4 -> 5
        # 5 -> 6
        # 6 -> 8
        scale = Math.ceil portfolioScale * 1.2
      
    else
      # Make the asset fit in the clipboard.
      scale = Math.min 1 / displayScale, fitScale

    contentWidth = width * scale
    contentHeight = height * scale

    borderWidth = if options.border then 7 else 0

    {contentWidth, contentHeight, borderWidth, scale}
  
  constructor: (@drawing) ->
    super arguments...

  onCreated: ->
    super arguments...
    
    @_wasDisplayingAsset = null
    
    @autorun (computation) =>
      displayingAsset = @drawing.portfolio().activeAsset()?
      
      if displayingAsset and not @_wasDisplayingAsset
        @audio.open()
        
      else if @_wasDisplayingAsset and not displayingAsset
        @audio.close()
      
      @_wasDisplayingAsset = displayingAsset
      
  asset: ->
    @drawing.portfolio().displayedAsset()?.asset
    
  activeClass: ->
    'active' if @drawing.activeAssetClass() and not @drawing.displayedAssetCustomComponent()

  onBackButton: ->
    # Relay to asset clipboard component.
    clipboardComponent = @drawing.portfolio().displayedAsset()?.asset.clipboardComponent
    result = clipboardComponent?.onBackButton?()
    return result if result?
