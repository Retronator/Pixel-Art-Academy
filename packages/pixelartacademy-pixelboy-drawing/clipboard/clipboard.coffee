AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PixelArtAcademy.PixelBoy.Apps.Drawing.Clipboard extends AM.Component
  @register 'PixelArtAcademy.PixelBoy.Apps.Drawing.Clipboard'
  
  constructor: (@drawing) ->
    super

  onCreated: ->
    super

    # Calculate sprite size.
    @spriteSize = new ComputedField =>
      return unless spriteData = @drawing.editor().spriteData()
      return unless assetData = @drawing.portfolio().displayedAsset()

      # Asset in the clipboard should be bigger than in the portfolio.
      # 1 -> 2
      # 2 -> 3
      # 3 -> 4
      # 4 -> 6
      # 5 -> 6
      # 6 -> 8
      # 7 -> 9
      assetScale = assetData.scale()
      scale = Math.ceil assetScale * 1.2
      
      # Check if the asset provides a maximum scale.
      if maxScale = assetData.asset.maxClipboardScale?()
        scale = Math.min scale, maxScale

      contentWidth = spriteData.bounds.width * scale
      contentHeight = spriteData.bounds.height * scale

      borderWidth = 7

      {contentWidth, contentHeight, borderWidth, scale}

  editorActive: ->
    @drawing.editor().active()

  asset: ->
    @drawing.portfolio().displayedAsset()?.asset

  editAsset: ->
    AB.Router.setParameter 'parameter4', 'edit'

  spritePlaceholderStyle: ->
    return unless spriteSize = @spriteSize()

    width: "#{spriteSize.contentWidth + 2 * spriteSize.borderWidth}rem"
    height: "#{spriteSize.contentHeight + 2 * spriteSize.borderWidth}rem"
