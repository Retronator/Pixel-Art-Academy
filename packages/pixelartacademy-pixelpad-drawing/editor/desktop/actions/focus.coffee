AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.Actions.Focus extends FM.Action
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.Actions.Focus'
  @displayName: -> "Move canvas"
  
  @initialize()

  constructor: ->
    super arguments...

    @desktop = @interface.ancestorComponentOfType PAA.PixelPad.Apps.Drawing.Editor.Desktop

  active: -> @desktop.focusedMode()

  execute: ->
    @desktop.focusedMode not @desktop.focusedMode()
