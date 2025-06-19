AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

# An instruction that is displayed until the step area is completed.
class PAA.Tutorials.Drawing.Instructions.Multiarea.UncompletedInstruction extends PAA.Tutorials.Drawing.Instructions.Multiarea.Instruction
  activeConditions: ->
    return unless asset = @getActiveAsset()
    
    return unless @stepAreaActive()
    
    # Show until the asset is completed.
    not asset.completed()
