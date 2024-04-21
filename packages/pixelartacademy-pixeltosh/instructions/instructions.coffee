AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.Instructions extends PAA.PixelPad.Systems.Instructions
  @id: -> 'PixelArtAcademy.Pixeltosh.Instructions'
  
  @version: -> '0.1.0'
  
  @register @id()
  template: -> @constructor.id()
  
  @fullName: -> "Pixeltosh instructions"
  @description: ->
    "
      System for on-demand display of information in the Pixeltosh app.
    "
  
  @initialize()
  
  @FaceClasses =
    Peaceful: 'peaceful'
    Smirk: 'smirk-up'
    OhNo: 'ohno'
  
  faceClass: ->
    if instruction = @targetDisplayedInstruction()
      return instruction.faceClass()
    
    return unless os = PAA.PixelPad.Apps.Pixeltosh.getOS()
    return unless os.isCreated()
    return unless osCursor = os.cursor()
    return unless coordinates = osCursor.coordinates()
    
    if coordinates.y < 180 then 'smirk-up' else 'smirk-down'
  
  speechBalloonStyle: ->
    height = @contentHeight()
    width = if height then @contentWidth() else 0
    
    width: "#{width}px"
    height: "#{height}px"
