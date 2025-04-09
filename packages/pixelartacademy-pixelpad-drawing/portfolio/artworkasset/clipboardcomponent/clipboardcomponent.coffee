AB = Artificial.Base
AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.PixelPad.Apps.Drawing.Portfolio.ArtworkAsset.ClipboardComponent extends AM.Component
  @register 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.ArtworkAsset.ClipboardComponent'
  @initializeDataComponent()
  
  constructor: (@artworkAsset) ->
    super arguments...
  
    @changeArtworkActive = new ReactiveField false
    @exportArtworkActive = new ReactiveField false
  
  onCreated: ->
    super arguments...

    @drawing = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing
  
    @palette = new ComputedField =>
      return unless palette = @artworkAsset.document()?.palette
      LOI.Assets.Palette.documents.findOne palette._id
      
    @extras = new ComputedField =>
      return unless document = @artworkAsset.document()
      extras = []
      
      Extra = PAA.PixelPad.Apps.Drawing.Portfolio.Forms.Extras.Extra
      
      for propertyName of document.properties
        typePropertyName = _.upperFirst propertyName
        
        # TODO: Remove when pixel art scaling is an option.
        continue if typePropertyName is Extra.Types.PixelArtScaling
        
        extras.push Extra.TypeNames[typePropertyName] if Extra.Types[typePropertyName]
        
      extras.join ', '

    # Calculate asset size.
    @assetSize = new ComputedField =>
      return unless document = @artworkAsset.document()
      return unless assetData = @drawing.portfolio().displayedAsset()

      options =
        border: document.properties?.canvasBorder
        pixelArtScaling: document.properties?.pixelArtScaling
  
      PAA.PixelPad.Apps.Drawing.Clipboard.calculateAssetSize assetData.scale(), document.bounds, options
    ,
      EJSON.equals

  onBackButton: ->
    if @secondPageActive()
      @closeSecondPage()
      
      # Inform that we've handled the back button.
      return true
      
  changeArtwork: ->
    @changeArtworkActive true
    
  exportArtwork: ->
    @exportArtworkActive true
  
  closeSecondPage: ->
    @changeArtworkActive false
    @exportArtworkActive false
  
  secondPageActive: ->
    @changeArtworkActive() or @exportArtworkActive()
    
  canEdit: -> PAA.PixelPad.Apps.Drawing.canEdit()
  
  canExport: ->
    # We can export if there's at least one layer.
    document = @artworkAsset.document()
    document.layers?.length or document.layerGroups?.length
  
  assetPlaceholderStyle: ->
    return unless assetSize = @assetSize()
    
    width: "#{assetSize.contentWidth + 2 * assetSize.borderWidth}rem"
    height: "#{assetSize.contentHeight + 2 * assetSize.borderWidth}rem"
    
  events: ->
    super(arguments...).concat
      'click .edit-button': @onClickEditButton
      'click .export-button': @onClickExportButton
      'click .trash-button': @onClickTrashButton
      'click .property.extras': @onClickPropertyExtras
      'click .back-button': @onClickBackButton
      'click .asset-placeholder': @onClickAssetPlaceholder

  onClickEditButton: (event) ->
    AB.Router.changeParameter 'parameter4', 'edit'
    
  onClickExportButton: (event) ->
    @exportArtwork()
    
  onClickTrashButton: (event) ->
    dialog = new LOI.Components.Dialog
      message: "Do you really want to destroy this artwork?"
      buttons: [
        text: "Trash"
        value: true
      ,
        text: "Cancel"
      ]

    LOI.adventure.showActivatableModalDialog
      dialog: dialog
      callback: =>
        return unless dialog.result
    
        artwork = @artworkAsset.artwork()
        
        # Remove artwork from the drawing app.
        artworks = PAA.PixelPad.Apps.Drawing.state 'artworks'
        _.remove artworks, (artworkEntry) => artworkEntry.artworkId is artwork._id
        PAA.PixelPad.Apps.Drawing.state 'artworks', artworks
        
        # Navigate away from the artwork.
        AB.Router.changeParameter 'parameter3', null
        
        # With a delay, remove the bitmap and the artwork from the database.
        Meteor.setTimeout =>
          PAA.Practice.Artworks.remove artwork
        ,
          1000
  
  onClickPropertyExtras: (event) ->
    @changeArtwork()
  
  onClickBackButton: (event) ->
    @closeSecondPage()
  
  onClickAssetPlaceholder: (event) ->
    engineBitmap = new LOI.Assets.Engine.PixelImage.Bitmap
      asset: @artworkAsset.document
      
    unless bitmapCanvas = engineBitmap.getCanvas()
      # There are no pixels in the bitmap yet, so just return an empty 1px image.
      bitmapCanvas = new AM.Canvas 1, 1
  
    artworkWithEmbeddedImage = _.clone @artworkAsset.artwork()
    artworkWithEmbeddedImage.image =
      src: bitmapCanvas.toDataURL('image/png')
      pixelScale: 1
    
    LOI.adventure.interface.focusArtworks [artworkWithEmbeddedImage],
      captionComponentClass: PAA.PixelPad.Apps.Drawing.Portfolio.ArtworkAsset.ArtworkCaption
  
  class @Title extends AM.DataInputComponent
    @register 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.NewArtwork.ClipboardComponent.Title'
    
    constructor: ->
      super arguments...
  
      @realtime = false
      @placeholder = "Untitled"
      
    load: ->
      artwork = @currentData()
      artwork.title
      
    save: (value) ->
      artwork = @currentData()
      PADB.Artwork.updateArtwork artwork._id,
        title: value
