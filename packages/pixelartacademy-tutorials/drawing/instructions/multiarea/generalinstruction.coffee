AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

# A general instruction that is displayed after a delay if the asset is not completed.
class PAA.Tutorials.Drawing.Instructions.Multiarea.GeneralInstruction extends PAA.Tutorials.Drawing.Instructions.Multiarea.Instruction
  @delayDuration: -> @defaultDelayDuration
  
  @resetDelayOnOperationExecuted: -> true

  activeConditions: ->
    return unless asset = @getActiveAsset()
    
    return unless @stepAreaActive()
    
    # Show until the asset is completed.
    not asset.completed()
