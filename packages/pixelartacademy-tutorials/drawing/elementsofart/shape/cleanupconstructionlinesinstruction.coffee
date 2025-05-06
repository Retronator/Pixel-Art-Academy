AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Shape.CleanUpConstructionLinesInstruction extends PAA.Tutorials.Drawing.Instructions.Instruction
  @id: -> "PixelArtAcademy.Tutorials.Drawing.ElementsOfArt.Shape.CleanUpConstructionLinesInstruction"
  @assetClass: -> PAA.Tutorials.Drawing.ElementsOfArt.Shape.AssetWithReferences

  @message: -> """
    Remove the blue color to clean up the line art.
  """

  @activeConditions: ->
    return unless asset = @getActiveAsset()
    
    # Show if any of the active steps are cleanup steps.
    for stepArea in asset.stepAreas() when not stepArea.completed()
      continue unless activeStep = stepArea.activeStep()
      return true if activeStep instanceof PAA.Tutorials.Drawing.ElementsOfArt.Shape.CleanConstructionLinesStep
    
    false
    
  @delayOnActivate: -> false
  @priority: -> 3
  
  @initialize()
