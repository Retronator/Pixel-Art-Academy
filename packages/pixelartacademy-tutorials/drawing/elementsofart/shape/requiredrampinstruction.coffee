AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Shape.RequiredRampInstruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
  @requiredRamp: -> throw new AE.NotImplementedException "Required ramp instruction must specify a required ramp."
  @requiredStepPropertyName: -> throw new AE.NotImplementedException "Required ramp instruction must specify what property to check to be the correct step."
  
  @activeConditions: ->
    return unless asset = @getActiveAsset()
    
    requiredStepPropertyName = @requiredStepPropertyName()
    
    # Show if any of the active steps has the required options property.
    for stepArea in asset.stepAreas()
      continue unless activeStep = stepArea.activeStep()
      return true if activeStep.options[requiredStepPropertyName]
    
    false
  
  delayDuration: ->
    defaultDelayDuration = super arguments...
    return defaultDelayDuration unless asset = @getActiveAsset()
    
    # Display immediately if there are no pixels of the required ramp.
    return defaultDelayDuration unless bitmap = asset.bitmap()
    bitmapLayer = bitmap.layers[0]
    
    requiredRamp = @constructor.requiredRamp()
    
    for x in [0...bitmap.bounds.width]
      for y in [0...bitmap.bounds.height]
        continue unless pixel = bitmapLayer.getPixel x, y
        return defaultDelayDuration if pixel.paletteColor.ramp is requiredRamp
    
    0
