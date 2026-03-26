AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.Design.ShapeLanguage.ReferencesTrayInstruction extends PAA.Tutorials.Drawing.Instructions.ReferencesTrayInstruction
  @id: -> "PixelArtAcademy.Tutorials.Drawing.Design.ShapeLanguage.ReferencesTrayInstruction"

  @assetClass: -> PAA.Tutorials.Drawing.Design.ShapeLanguage.AssetWithReferences
  @firstAssetClass: -> PAA.Tutorials.Drawing.Design.ShapeLanguage.Circle2
  
  @message: -> """
    Open the references tray and choose a game you want to learn from.
  """
  
  @initialize()
  
  class @More extends PAA.Tutorials.Drawing.Instructions.Multiarea.Instruction
    @id: -> "PixelArtAcademy.Tutorials.Drawing.Design.ShapeLanguage.ReferencesTrayInstruction.More"
    @assetClass: -> PAA.Tutorials.Drawing.Design.ShapeLanguage.AssetWithReferences
    
    @message: -> """
      Choose another reference to learn more or return to the portfolio to complete the lesson.
    """
    
    @priority: -> -1
    
    activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show once the active area is completed.
      activeStepAreaIndex = @activeStepAreaIndex()
      return unless activeStepAreaIndex?
      return unless asset.stepAreas()[activeStepAreaIndex]?.completed()
      
      # Show if there are any references left to be drawn.
      bitmap = asset.bitmap()
      bitmap.references.length > asset.stepAreas().length
    
    @initialize()
