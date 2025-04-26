AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.ReferencesTrayInstruction extends PAA.Tutorials.Drawing.Instructions.Instruction
  @assetClass: -> throw new AE.NotImplementedException "Error instruction must provide which assets to be displayed with."
  @firstAssetClass: -> throw new AE.NotImplementedException "Error instruction must provide which is the first of the assets."
  
  @getActiveAsset: ->
    # We must be in the editor on the provided asset.
    return unless editor = @getEditor()
    return unless editor.drawingActive()
    
    return unless asset = editor.activeAsset()
    return unless asset instanceof @assetClass()
    
    asset
  
  @activeConditions: ->
    return unless asset = @getActiveAsset()
    
    # Show until the image has a displayed reference.
    bitmap = asset.bitmap()
    displayedReferences = _.filter bitmap.references, (reference) => reference.displayed
    not displayedReferences.length
    
  @delayDuration: ->
    return @defaultDelayDuration unless asset = @getActiveAsset()
  
    # Only the first asset with references needs immediate instructions.
    if asset instanceof @firstAssetClass() then 0 else @defaultDelayDuration
  
  @priority: -> 1
