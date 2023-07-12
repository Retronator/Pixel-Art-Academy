AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.Instructions.Desktop extends PAA.PixelPad.Systems.Instructions
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.Instructions.Desktop'

  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Desktop editor drawing instructions"
  @description: ->
    "
      System for on-demand display of information in the Drawing app with the Desktop editor.
    "

  @initialize()

  constructor: ->
    super arguments...
  
    @headerHeight = 14
    @animationDuration = 0.35
