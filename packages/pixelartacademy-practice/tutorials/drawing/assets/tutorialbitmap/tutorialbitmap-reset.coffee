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
    if references = bitmapData.references
      newReferences = for reference in references
        image: reference.image
        position:
          x: 100 * (Math.random() - 0.5)
          y: 100 * (Math.random() - 0.5)
      
      bitmapData.references = newReferences
      
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
