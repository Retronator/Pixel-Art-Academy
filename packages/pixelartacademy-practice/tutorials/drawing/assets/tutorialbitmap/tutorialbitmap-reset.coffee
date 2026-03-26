AB = Artificial.Base
AM = Artificial.Mirage
AMu = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @reset: (tutorial, bitmapId) ->
    @_createBitmapData()
      .then((bitmapData) => @_setBitmapDataReferences bitmapData)
      .then((bitmapData) => @_setBitmapDataPalette bitmapData)
      .then((bitmapData) => @_updateBitmap tutorial, bitmapId, bitmapData)
      .catch (error) =>
        console.error error
        throw new AE.InvalidOperationException "Could not reset tutorial bitmap."
  
  @_updateBitmap: (tutorial, bitmapId, bitmapData) ->
    LOI.Assets.Bitmap.documents.update bitmapId, bitmapData
    
    @_initializeLayers LOI.Assets.Bitmap.versionedDocuments.getDocumentForId bitmapId
  
    # Trigger reactivity.
    LOI.Assets.Bitmap.versionedDocuments.reportNonVersionedChange bitmapId
    
    # Reset the asset instance.
    asset = tutorial.getAsset @id()
    asset.reset()
    
  reset: ->
    # Nothing to reset if we haven't initialized yet (resetting will be called when first creating the bitmap).
    return unless @initialized()
    
    # Prevent recomputation of completed states while resetting.
    @resetting true
    
    # Reset all steps.
    stepArea.reset() for stepArea in @stepAreas()
    
    # Remove any asset data.
    if assetData = @getAssetData()
      assetData.stepAreas = []
      assetData.completed = false
      
      @setAssetData assetData
    
    # Unlock recomputation after changes have been applied.
    Tracker.afterFlush => @resetting false
