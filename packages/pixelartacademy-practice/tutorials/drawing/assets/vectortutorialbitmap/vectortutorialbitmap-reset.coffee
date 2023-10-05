AB = Artificial.Base
AM = Artificial.Mirage
AMu = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Tutorials.Drawing.Assets.VectorTutorialBitmap extends PAA.Practice.Tutorials.Drawing.Assets.VectorTutorialBitmap
  @reset: (assetId, bitmapId) ->
    # Build the original state.
    assetClass = PAA.Practice.Project.Asset.getClassForId assetId
  
    pixels = []
    bitmap = LOI.Assets.Bitmap.versionedDocuments.getDocumentForId bitmapId

    # Mark all transparent pixels for removal (add pixel with just coordinates).
    for x in [0...bitmap.bounds.width]
      for y in [0...bitmap.bounds.height]
        pixels.push {x, y} unless _.find pixels, (pixel) => pixel.x is x and pixel.y is y
    
    # Replace the layer pixels in this bitmap.
    strokeAction = new LOI.Assets.Bitmap.Actions.Stroke @id(), bitmap, [0], pixels
    AMu.Document.Versioning.executeAction bitmap, bitmap.lastEditTime, strokeAction, new Date

    # Clear the history.
    AMu.Document.Versioning.clearHistory bitmap

    if references = assetClass.references?()
      # Rebuild references but use the existing image data.
      bitmapData = LOI.Assets.Bitmap.documents.findOne bitmapId
      newReferences = []
  
      for reference in references
        # Allow sending in just the reference URL.
        imageUrl = if _.isString reference then reference else reference.image.url
        reference = {} if _.isString reference
    
        existingReference = _.find bitmapData.references, (bitmapReference) => bitmapReference.image.url is imageUrl
    
        newReferences.push _.defaults
          image: _.pick existingReference.image, ['_id', 'url']
        ,
          reference
      
      LOI.Assets.Bitmap.documents.update bitmapId,
        $set:
          references: newReferences
    
      LOI.Assets.Bitmap.versionedDocuments.reportNonVersionedChange bitmapId
