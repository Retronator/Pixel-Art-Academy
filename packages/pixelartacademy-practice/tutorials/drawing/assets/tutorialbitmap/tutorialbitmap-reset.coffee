AB = Artificial.Base
AM = Artificial.Mirage
AMu = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @reset: (tutorial, assetId, bitmapId) ->
    @_resetBitmapData(bitmapId)
      .then((bitmapData) => @_resetBitmapDataReferences bitmapData)
      .then((bitmapData) => @_resetBitmap bitmapData, tutorial, assetId)
      .catch (error) =>
        console.error error
        throw new AE.InvalidOperationException "Could not reset tutorial bitmap."
  
  @_resetBitmapData: (bitmapId) ->
    new Promise (resolve, reject) =>
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
      
      # Reset properties.
      if properties = @properties()
        bitmapData.properties = properties
        
      resolve bitmapData
      
  @_resetBitmapDataReferences: (bitmapData) ->
    new Promise (resolve, reject) =>
      unless references = @references?()
        resolve bitmapData
        return
        
      referencePromises = []
    
      for reference in references
        imageUrl = if _.isString reference then reference else reference.image.url
        
        do (imageUrl) =>
          reference = {} if _.isString reference
          existingReference = _.find bitmapData.references, (bitmapReference) => bitmapReference.image.url is imageUrl
          
          # Find the ID of the image with this URL.
          referencePromises.push new Promise (resolve, reject) =>
            Tracker.autorun (computation) ->
              unless image = existingReference?.image
                LOI.Assets.Image.forUrl.subscribe imageUrl
                LOI.Assets.Image.forUrl.subscribeContent imageUrl
                return unless image = LOI.Assets.Image.documents.findOne url: imageUrl

              computation.stop()
              
              # We need to copy extra meta data (like displayOptions from existing ones).
              resolve _.defaults
                image: image
                position:
                  x: 100 * (Math.random() - 0.5)
                  y: 100 * (Math.random() - 0.5)
              ,
                reference

      Promise.all(referencePromises).then (references) =>
        bitmapData.references = references
        resolve bitmapData

  @_resetBitmap: (bitmapData, tutorial, assetId) ->
    # Update persistent document.
    LOI.Assets.Bitmap.documents.update bitmapData._id, bitmapData
    
    # Trigger reactivity.
    LOI.Assets.Bitmap.versionedDocuments.reportNonVersionedChange bitmapData._id
    
    # Reset the asset and its data.
    assets = tutorial.assets()
    asset = _.find assets, (asset) => asset.id() is assetId
    asset.reset()
