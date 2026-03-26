AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.Editor.Easel.Actions.DisplayMode extends FM.Action
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Easel.Actions.DisplayMode'
  @displayName: -> "Cycle display mode"
  
  @initialize()

  constructor: ->
    super arguments...

    @easel = @interface.ancestorComponentOfType PAA.PixelPad.Apps.Drawing.Editor.Easel

  execute: ->
    @easel.cycleDisplayMode()
