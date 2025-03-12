AB = Artificial.Base
AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.PixelPad.Apps.Drawing.Portfolio.ArtworkAsset.ClipboardComponent extends AM.Component
  @register 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.ArtworkAsset.ClipboardComponent'
  @initializeDataComponent()
  
  constructor: (@artworkAsset) ->
    super arguments...
  
    @secondPageActive = new ReactiveField false
  
  onCreated: ->
    super arguments...

    @drawing = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing
  
    @palette = new ComputedField =>
      return unless palette = @artworkAsset.document()?.palette
      LOI.Assets.Palette.documents.findOne palette._id
      
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

  canEdit: -> PAA.PixelPad.Apps.Drawing.canEdit()
  canUpload: -> PAA.PixelPad.Apps.Drawing.canEdit() or PAA.PixelPad.Apps.Drawing.canUpload()
  
  assetPlaceholderStyle: ->
    return unless assetSize = @assetSize()
    
    width: "#{assetSize.contentWidth + 2 * assetSize.borderWidth}rem"
    height: "#{assetSize.contentHeight + 2 * assetSize.borderWidth}rem"
    
  events: ->
    super(arguments...).concat
      'click .edit-button': @onClickEditButton
      'click .trash-button': @onClickTrashButton

  onClickEditButton: (event) ->
    AB.Router.changeParameter 'parameter4', 'edit'
    
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
