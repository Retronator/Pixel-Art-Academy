AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Drawing.Editor.Desktop.Actions.Focus extends FM.Action
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Drawing.Editor.Desktop.Actions.Focus'
  @displayName: -> "Focus mode"
  
  @initialize()

  constructor: ->
    super arguments...

    @desktop = @interface.ancestorComponentOfType PAA.PixelBoy.Apps.Drawing.Editor.Desktop

  active: -> @desktop.focusedMode()

  execute: ->
    @desktop.focusedMode not @desktop.focusedMode()
