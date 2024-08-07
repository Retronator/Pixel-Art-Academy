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
      
    # Calculate asset size.
    @assetSize = new ComputedField =>
      return unless document = @artworkAsset.document()
      return unless assetData = @drawing.portfolio().displayedAsset()
  
      PAA.PixelBoy.Apps.Drawing.Clipboard.calculateAssetSize assetData.scale(), document.bounds
    ,
      EJSON.equals

  canEdit: -> PAA.PixelBoy.Apps.Drawing.canEdit()
  canUpload: -> PAA.PixelBoy.Apps.Drawing.canUpload()
  
  assetPlaceholderStyle: ->
    return unless assetSize = @assetSize()
    
    width: "#{assetSize.contentWidth + 2 * assetSize.borderWidth}rem"
    height: "#{assetSize.contentHeight + 2 * assetSize.borderWidth}rem"
    
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
