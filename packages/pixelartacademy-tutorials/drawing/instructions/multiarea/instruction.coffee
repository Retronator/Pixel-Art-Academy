AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
AMu = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

# A general instruction that is displayed after a delay if the asset is not completed at a specific active step.
class PAA.Tutorials.Drawing.Instructions.Multiarea.Instruction extends PAA.Tutorials.Drawing.Instructions.Instruction
  @referenceUrl: -> throw new AE.NotImplementedException "A multiarea instruction must specify to which reference it applies."
  
  constructor: ->
    super arguments...
    
    # Track the step area where the latest progress was made.
    @activeStepAreaIndex = new ReactiveField null
    
    @_updateActiveStepAreaAutorun = Tracker.autorun =>
      return unless asset = @getActiveAsset()
      return unless bitmap = asset.bitmap()
      
      # Look at the last operation.
      return unless lastAction = AMu.Document.Versioning.ActionArchive.getLastActionForDocument asset.bitmapId()
      
      operations = _.reverse lastAction.forward
      
      for operation in operations
        if operation instanceof LOI.Assets.VisualAsset.Operations.UpdateReference
          # Find which reference was changed and which step area it corresponds to.
          referenceUrl = bitmap.references[operation.index].image.url
          @activeStepAreaIndex _.findIndex asset.stepAreas(), (stepArea) => stepArea.data().referenceUrl is referenceUrl
          break
        
        if operation instanceof LOI.Assets.Bitmap.Operations.ChangePixels
          # Find which step area's pixels were changed.
          centralPixel =
            x: operation.bounds.x + operation.bounds.width / 2
            y: operation.bounds.y + operation.bounds.height / 2
          
          fixedDimensions = asset.constructor.fixedDimensions()
          
          switch asset.constructor.canvasExtensionDirection()
            when TutorialBitmap.CanvasExtensionDirection.Horizontal
              @activeStepAreaIndex Math.floor centralPixel.x / fixedDimensions.width
            
            when TutorialBitmap.CanvasExtensionDirection.Vertical
              @activeStepAreaIndex Math.floor centralPixel.y / fixedDimensions.height
    
  destroy: ->
    super arguments...
    
    @_updateActiveStepAreaAutorun.stop()
    
  stepAreaActive: ->
    return unless asset = @getActiveAsset()
    activeStepAreaIndex = @activeStepAreaIndex()
    return unless activeStepAreaIndex?
    
    asset.stepAreas()[activeStepAreaIndex]?.data().referenceUrl is @constructor.referenceUrl()
    
  getStepArea: ->
    return unless asset = @getActiveAsset()
    referenceUrl = @constructor.referenceUrl()
    
    _.find asset.stepAreas(), (stepArea) => stepArea.data().referenceUrl is referenceUrl
