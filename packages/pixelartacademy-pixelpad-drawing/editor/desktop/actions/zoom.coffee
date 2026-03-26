AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class Zoom extends FM.Action
  enabled: -> @interface.activeFileId()? and @newZoomLevel()

  constructor: ->
    super arguments...

    @zoomLevels = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.ZoomLevels

    @zoomPercentage = new ComputedField =>
      @interface.getEditorForActiveFile()?.camera()?.targetScale() * 100

  execute: ->
    return unless newZoomLevel = @newZoomLevel()

    @interface.getEditorForActiveFile()?.camera()?.scaleTo newZoomLevel / 100, 0.2

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.Actions.ZoomIn extends Zoom
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.Actions.ZoomIn'
  @displayName: -> "Zoom in"

  @initialize()

  newZoomLevel: ->
    percentage = @zoomPercentage()

    for zoomLevel in @zoomLevels()
      if Math.round(zoomLevel) > Math.round(percentage)
        return zoomLevel

    null

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.Actions.ZoomOut extends Zoom
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.Actions.ZoomOut'
  @displayName: -> "Zoom out"

  @initialize()

  newZoomLevel: ->
    percentage = @zoomPercentage()

    for zoomLevel in @zoomLevels() by -1
      if Math.round(zoomLevel) < Math.round(percentage)
        return zoomLevel

    null
