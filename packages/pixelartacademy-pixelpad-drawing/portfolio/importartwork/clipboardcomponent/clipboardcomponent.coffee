AB = Artificial.Base
AM = Artificial.Mirage
AMu = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.PixelPad.Apps.Drawing.Portfolio.ImportArtwork.ClipboardComponent extends AM.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.ImportArtwork.ClipboardComponent'
  @register @id()
  
  @initializeDataComponent()

  events: ->
    super(arguments...).concat
      'click .upload-button': @onClickUploadButton
  
  onClickUploadButton: (event) ->
    event.preventDefault()
    
    $fileInput = $('<input type="file"/>')
    
    $fileInput.on 'change', (event) =>
      return unless file = $fileInput[0]?.files[0]
      
      image = new Image
      image.onload = => @_onImportImage file.name, image
      image.src = URL.createObjectURL file
    
    $fileInput.click()
    
  _onImportImage: (title, image) ->
    artworkInfo = {title}
    
    artworkInfo.size =
      width: image.width
      height: image.height
    
    artworkInfo.properties =
      pixelArtScaling: true
      pixelArtEvaluation:
        editable: true
      
    artwork = PAA.Practice.Artworks.insert artworkInfo
    
    # Add artwork to the drawing app.
    artworks = PAA.PixelPad.Apps.Drawing.state('artworks') or []
    artworks.push artworkId: artwork._id
    PAA.PixelPad.Apps.Drawing.state 'artworks', artworks
    
    # Place the pixels.
    documentRepresentation = _.find artwork.representations, (representation) => representation.type is PADB.Artwork.RepresentationTypes.Document
    
    # Extract the type and ID.
    url = new URL Meteor.absoluteUrl documentRepresentation.url
    bitmapId = url.searchParams.get 'id'
    
    canvas = new AM.ReadableCanvas image
    imageData = canvas.getFullImageData()
    
    pixels = []
    
    for x in [0...imageData.width]
      for y in [0...imageData.height]
        pixelIndex = (x + y * imageData.width) * 4
        
        # Skip transparent pixels.
        a = imageData.data[pixelIndex + 3]
        continue unless a
        
        r = imageData.data[pixelIndex] / 255
        g = imageData.data[pixelIndex + 1] / 255
        b = imageData.data[pixelIndex + 2] / 255
      
        pixel =
          x: x
          y: y
          directColor: {r, g, b}
          alpha: 1
      
        pixels.push pixel if pixel
      
    # Add the pixels.
    action = new AMu.Document.Versioning.Action @constructor.id()
    bitmap = LOI.Assets.Bitmap.versionedDocuments.getDocumentForId bitmapId
    
    addLayerAction = new LOI.Assets.Bitmap.Actions.AddLayer bitmapId, bitmap
    AMu.Document.Versioning.executePartialAction bitmap, addLayerAction
    action.append addLayerAction
    
    strokeAction = new LOI.Assets.Bitmap.Actions.Stroke bitmapId, bitmap, [0], pixels
    AMu.Document.Versioning.executePartialAction bitmap, strokeAction
    action.append strokeAction
    
    AMu.Document.Versioning.executeAction bitmap, bitmap.lastEditTime, action, new Date
    AMu.Document.Versioning.clearHistory bitmap
    
    # Navigate to the artwork.
    AB.Router.changeParameter 'parameter3', artwork._id
