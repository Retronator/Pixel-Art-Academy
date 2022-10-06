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

    # Calculate asset size.
    @assetSize = new ComputedField =>
      return unless spriteData = @asset.sprite()
      return unless assetData = @drawing.portfolio().displayedAsset()

      options =
        scaleLimits: {}

      # Check if the asset provides a minimum or maximum scale.
      if minScale = @asset.minClipboardScale?()
        options.scaleLimits.min = minScale
  
      if maxScale = @asset.maxClipboardScale?()
        options.scaleLimits.max = maxScale
      
      PAA.PixelBoy.Apps.Drawing.Clipboard.calculateAssetSize assetData.scale(), spriteData.bounds, options
      
  onBackButton: ->
    if @secondPageActive()
      @closeSecondPage()
    
      # Inform that we've handled the back button.
      return true

  editorActive: ->
    @drawing.editor().active()

  editAsset: ->
    AB.Router.setParameter 'parameter4', 'edit'
    
  showSecondPage: ->
    @secondPageActive true

  closeSecondPage: ->
    @secondPageActive false

  assetPlaceholderStyle: ->
    return unless assetSize = @assetSize()

    width: "#{assetSize.contentWidth + 2 * assetSize.borderWidth}rem"
    height: "#{assetSize.contentHeight + 2 * assetSize.borderWidth}rem"
    
  events: ->
    super(arguments...).concat
      'click .back-button': @onClickBackButton

  onClickBackButton: (event) ->
    @closeSecondPage()
