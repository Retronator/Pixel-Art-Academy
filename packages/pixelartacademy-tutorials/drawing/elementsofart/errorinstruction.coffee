AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.ErrorInstruction extends PAA.Tutorials.Drawing.Instructions.Instruction
  @assetClass: -> throw new AE.NotImplementedException "Error instruction must provide which assets to be displayed with."
    
  @activeConditions: ->
    return unless asset = @getActiveAsset()
    
    # Show when there are any extra pixels present.
    return unless asset.hasExtraPixels()
    
    # Wait for the stroke to have finished.
    editor = @getEditor()
    activeTool = editor.interface.activeTool()
    
    return true unless activeTool instanceof LOI.Assets.SpriteEditor.Tools.Pencil
    
    pencil = activeTool
    not pencil.strokeActive()
  
  @priority: -> 1
