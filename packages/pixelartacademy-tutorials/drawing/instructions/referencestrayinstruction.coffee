AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.Instructions.ReferencesTrayInstruction extends PAA.Tutorials.Drawing.Instructions.Instruction
  @assetClass: -> throw new AE.NotImplementedException "References tray instruction must provide which assets to be displayed with."
  @firstAssetClass: -> throw new AE.NotImplementedException "References tray instruction must provide which is the first of the assets."
  
  @activeConditions: ->
    return unless asset = @getActiveAsset()
    
    # Show until a step area is created.
    not asset.stepAreas().length
    
  @delayDuration: ->
    return @defaultDelayDuration unless asset = @getActiveAsset()
  
    # Only the first asset with references needs immediate instructions.
    if asset instanceof @firstAssetClass() then 0 else @defaultDelayDuration
  
  @priority: -> 1
