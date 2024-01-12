AB = Artificial.Base
AM = Artificial.Mirage
AMu = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @reset: (tutorial, assetId, bitmapId) ->
    # Build the original state.
    bitmap = LOI.Assets.Bitmap.versionedDocuments.getDocumentForId bitmapId
    
    # Crop to initial size if needed.
    size = @fixedDimensions()
    
    unless bitmap.bounds.width is size.width and bitmap.bounds.height is size.height
      bitmap.crop
        left: 0
        right: size.width - 1
        top: 0
        bottom: size.height - 1
        fixed: true
    
    # Clear the pixels and history.
    bitmap.clear()
    AMu.Document.Versioning.clearHistory bitmap
    
    # Prepare persistent document data.
    bitmapData = bitmap.toPlainObject()
    
    # Reset references.
    if references = @references?()
      bitmapData.references = for reference in references
        imageUrl = if _.isString reference then reference else reference.image.url
        reference = {} if _.isString reference
        
        existingReference = _.find bitmapData.references, (bitmapReference) => bitmapReference.image.url is imageUrl
        
        # We need to copy extra meta data (like displayOptions from existing ones).
        _.defaults
          image: existingReference.image
          position:
            x: 100 * (Math.random() - 0.5)
            y: 100 * (Math.random() - 0.5)
        ,
          reference
      
    # Reset properties.
    if properties = @properties()
      bitmapData.properties = properties
    
    # Update persistent document.
    LOI.Assets.Bitmap.documents.update bitmapData._id, bitmapData
    
    # Trigger reactivity.
    LOI.Assets.Bitmap.versionedDocuments.reportNonVersionedChange bitmapId
    
    # Reset pre-existing asset data.
    assets = tutorial.assetsData()
    
    if asset = _.find assets, (asset) => asset.id is assetId
      asset.stepAreas = []
      asset.completed = false
      
      tutorial.state 'assets', assets
