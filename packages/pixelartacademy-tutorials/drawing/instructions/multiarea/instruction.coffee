AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
AMu = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

# A general instruction that is displayed after a delay if the asset is not completed at a specific active step.
class PAA.Tutorials.Drawing.Instructions.Multiarea.Instruction extends PAA.Tutorials.Drawing.Instructions.Instruction
  @referenceUrl: -> null # Override if this instruction is for a specific reference (otherwise it applies to all).
  
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
          activeStepAreaIndex = _.findIndex asset.stepAreas(), (stepArea) => stepArea.data().referenceUrl is referenceUrl
          @activeStepAreaIndex if activeStepAreaIndex > -1 then activeStepAreaIndex else null
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
    
    return true unless specificReferenceUrl = @constructor.referenceUrl()
    
    asset.stepAreas()[activeStepAreaIndex]?.data().referenceUrl is specificReferenceUrl
    
  getStepArea: ->
    return unless asset = @getActiveAsset()
  
    if specificReferenceUrl = @constructor.referenceUrl()
      _.find asset.stepAreas(), (stepArea) => stepArea.data().referenceUrl is specificReferenceUrl
      
    else
      # Since this instruction is not specific to one reference, it applies to any step area, including the current one.
      asset.stepAreas()[@activeStepAreaIndex()]
