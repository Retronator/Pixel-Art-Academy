LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Practice.Tutorials.Drawing.InstructionsMarkupEngineComponent extends PAA.Practice.Helpers.Drawing.Markup.EngineComponent
  constructor: ->
    super arguments...
    
    @markup = new ComputedField =>
      return unless pixelPad = LOI.adventure.getCurrentThing PAA.PixelPad
      return unless instructions = pixelPad.os.getSystem PAA.PixelPad.Systems.Instructions
      return unless instruction = instructions.displayedInstruction()
      instruction.markup?()

  drawToContext: (context, renderOptions = {}) ->
    return unless markup = @markup()
    
    @drawMarkup markup, context,
      pixelSize: 1 / renderOptions.camera.effectiveScale() * devicePixelRatio
      displayPixelSize: 1 / renderOptions.camera.effectiveScale() * renderOptions.editor.display.scale()
