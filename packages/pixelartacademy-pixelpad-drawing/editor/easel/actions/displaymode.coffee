AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Drawing.Editor.Easel.Actions.DisplayMode extends FM.Action
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Drawing.Editor.Easel.Actions.DisplayMode'
  @displayName: -> "Cycle display mode"
  
  @initialize()

  constructor: ->
    super arguments...

    @easel = @interface.ancestorComponentOfType PAA.PixelBoy.Apps.Drawing.Editor.Easel

  execute: ->
    @easel.cycleDisplayMode()
