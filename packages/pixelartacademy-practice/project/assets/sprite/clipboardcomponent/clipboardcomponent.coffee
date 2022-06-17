AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Practice.Project.Asset.Sprite.ClipboardComponent extends AM.Component
  @register 'PixelArtAcademy.Practice.Project.Asset.Sprite.ClipboardComponent'
  
  constructor: (@asset) ->
    super arguments...

    @secondPageActive = new ReactiveField false

  onCreated: ->
    super arguments...
    
    @drawing = @ancestorComponentOfType PAA.PixelBoy.Apps.Drawing

    # Calculate sprite size.
    @spriteSize = new ComputedField =>
      return unless spriteData = @drawing.editor().spriteData()
      return unless assetData = @drawing.portfolio().displayedAsset()

      # Asset in the clipboard should be bigger than in the portfolio.
      assetScale = assetData.scale()

      if assetScale < 1
        # Scale up to 0.5 to show pixel perfect at least on retina screens.
        scale = 0.5

      else
        # 1 -> 2
        # 2 -> 3
        # 3 -> 4
        # 4 -> 5
        # 5 -> 6
        # 6 -> 8
        # 7 -> 9
        scale = Math.ceil assetScale * 1.2

      # Check if the asset provides a minimum or maximum scale.
      if minScale = assetData.asset.minClipboardScale?()
        scale = Math.max scale, minScale

      if maxScale = assetData.asset.maxClipboardScale?()
        scale = Math.min scale, maxScale

      contentWidth = spriteData.bounds.width * scale
      contentHeight = spriteData.bounds.height * scale

      borderWidth = 7

      {contentWidth, contentHeight, borderWidth, scale}
      
  onBackButton: ->
    if @secondPageActive()
      @closeSecondPage()
    
      # Inform that we've handled the back button.
      return true

  editorActive: ->
    @drawing.editor().active()

  asset: ->
    @drawing.portfolio().displayedAsset()?.asset

  editAsset: ->
    AB.Router.setParameter 'parameter4', 'edit'
    
  showSecondPage: ->
    @secondPageActive true

  closeSecondPage: ->
    @secondPageActive false

  spritePlaceholderStyle: ->
    return unless spriteSize = @spriteSize()

    width: "#{spriteSize.contentWidth + 2 * spriteSize.borderWidth}rem"
    height: "#{spriteSize.contentHeight + 2 * spriteSize.borderWidth}rem"
    
  events: ->
    super(arguments...).concat
      'click .back-button': @onClickBackButton

  onClickBackButton: (event) ->
    @closeSecondPage()
