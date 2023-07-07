AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Practice.Project.Asset.Bitmap.ClipboardComponent extends AM.Component
  @register 'PixelArtAcademy.Practice.Project.Asset.Bitmap.ClipboardComponent'
  
  constructor: (@asset) ->
    super arguments...

    @secondPageActive = new ReactiveField false

  onCreated: ->
    super arguments...
    
    @drawing = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing

    # Calculate asset size.
    @assetSize = new ComputedField =>
      return unless bitmapData = @asset.bitmap()
      return unless assetData = @drawing.portfolio().displayedAsset()

      options =
        scaleLimits: {}

      # Check if the asset provides a minimum or maximum scale.
      if minScale = @asset.minClipboardScale?()
        options.scaleLimits.min = minScale
  
      if maxScale = @asset.maxClipboardScale?()
        options.scaleLimits.max = maxScale
      
      PAA.PixelPad.Apps.Drawing.Clipboard.calculateAssetSize assetData.scale(), bitmapData.bounds, options
      
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
