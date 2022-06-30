AB = Artificial.Base
AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.PixelBoy.Apps.Drawing.Portfolio.ArtworkAsset.ClipboardComponent extends AM.Component
  @register 'PixelArtAcademy.PixelBoy.Apps.Drawing.Portfolio.ArtworkAsset.ClipboardComponent'
  @initializeDataComponent()
  
  constructor: (@artworkAsset) ->
    super arguments...
  
    @secondPageActive = new ReactiveField false
  
  onCreated: ->
    super arguments...

    @drawing = @ancestorComponentOfType PAA.PixelBoy.Apps.Drawing
  
    @palette = new ComputedField =>
      return unless palette = @artworkAsset.document()?.palette
      LOI.Assets.Palette.documents.findOne palette._id
      
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
    ,
      EJSON.equals

  canEdit: -> PAA.PixelBoy.Apps.Drawing.canEdit()
  canUpload: -> PAA.PixelBoy.Apps.Drawing.canUpload()
  
  spritePlaceholderStyle: ->
    return unless spriteSize = @spriteSize()
    
    width: "#{spriteSize.contentWidth + 2 * spriteSize.borderWidth}rem"
    height: "#{spriteSize.contentHeight + 2 * spriteSize.borderWidth}rem"
    
  events: ->
    super(arguments...).concat
      'click .edit-button': @onClickEditButton

  onClickEditButton: (event) ->
    AB.Router.setParameter 'parameter4', 'edit'
  
  class @Title extends AM.DataInputComponent
    @register 'PixelArtAcademy.PixelBoy.Apps.Drawing.Portfolio.NewArtwork.ClipboardComponent.Title'
    
    constructor: ->
      super arguments...
  
      @realtime = false
      @placeholder = "Untitled"
      
    load: ->
      artwork = @currentData()
      artwork.title
      
    save: (value) ->
      artwork = @currentData()
      PADB.Artwork.updateCharacterArtwork LOI.characterId(), artwork._id,
        title: value
