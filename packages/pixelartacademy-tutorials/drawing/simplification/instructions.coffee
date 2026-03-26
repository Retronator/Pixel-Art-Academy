AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.Simplification.ReferencesTrayInstruction extends PAA.Tutorials.Drawing.Instructions.ReferencesTrayInstruction
  @id: -> "PixelArtAcademy.Tutorials.Drawing.Simplification.ReferencesTrayInstruction"
  
  @assetClass: -> PAA.Tutorials.Drawing.Simplification.AssetWithReferences
  @firstAssetClass: -> PAA.Tutorials.Drawing.Simplification.Silhouette
  
  @message: -> """
    Open the references tray and choose an object to draw.
  """
  
  @initialize()
  
class PAA.Tutorials.Drawing.Simplification.MeshMorphingInstruction extends PAA.Tutorials.Drawing.Instructions.Multiarea.Instruction
  getMeshMorphing: ->
    return unless stepAreaData = @getStepArea()?.data()
    return unless asset = @getActiveAsset()
    return unless bitmapReferences = asset.bitmap()?.references
    return unless referenceData = _.find bitmapReferences, (reference) => reference.image.url is stepAreaData.referenceUrl
    referenceData.displayOptions?.meshMorphing

  activeConditions: ->
    return unless asset = @getActiveAsset()
    return if asset.completed()
    return unless asset.constructor.meshMorphingInstructions
    return unless @stepAreaActive()
    return unless @getMeshMorphing()
    
    # Show modification instructions while input is active on the reference.
    return unless stepAreaData = @getStepArea()?.data()
    return unless referenceData = asset.getReferenceDataForUrl stepAreaData.referenceUrl
    referenceData.displayOptions?.input
  
class @DrawLinesInstruction extends PAA.Tutorials.Drawing.Simplification.MeshMorphingInstruction
  @id: -> "PixelArtAcademy.Tutorials.Drawing.Simplification.DrawLinesInstruction"
  @assetClass: -> PAA.Tutorials.Drawing.Simplification.AssetWithReferences
  
  @message: -> """
    Draw the lines when you are happy with the look of the object.
  """
  
  @initialize()
  
  activeConditions: ->
    return unless super arguments...
    not @getStepArea().steps()[0].options.fill
    
class @FillSilhouette extends PAA.Tutorials.Drawing.Simplification.MeshMorphingInstruction
  @id: -> "PixelArtAcademy.Tutorials.Drawing.Simplification.FillSilhouette"
  @assetClass: -> PAA.Tutorials.Drawing.Simplification.AssetWithReferences
  
  @message: -> """
    Fill in the silhouette when you are happy with the look of the object.
  """
  
  @initialize()
  
  activeConditions: ->
    return unless super arguments...
    @getStepArea().steps()[0].options.fill
