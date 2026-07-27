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

    # Use animated scaleTo for the desktop editor instead of setScale.
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

class ZoomToScale extends FM.Action
  @scale: -> throw new AE.NotImplementedException "Zoom to scale must specify which scale it zooms to."
  @displayName: -> "Zoom to #{@scale() * 100}%"

  execute: (temporary) ->
    return unless camera = @interface.getEditorForActiveFile()?.camera()

    if temporary
      if @_lastScale
        scale = @_lastScale
        @_lastScale = null

      else
        @_lastScale = camera.scale()
        scale = @constructor.scale()

      camera.setScale scale

    else
      camera.scaleTo @constructor.scale(), 0.2

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.Actions.Zoom25 extends ZoomToScale
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.Actions.Zoom25'
  @scale: -> 0.25

  @initialize()

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.Actions.Zoom50 extends ZoomToScale
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.Actions.Zoom50'
  @scale: -> 0.5

  @initialize()

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.Actions.Zoom100 extends ZoomToScale
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.Actions.Zoom100'
  @scale: -> 1

  @initialize()

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.Actions.Zoom200 extends ZoomToScale
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.Actions.Zoom200'
  @scale: -> 2

  @initialize()

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.Actions.Zoom400 extends ZoomToScale
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.Actions.Zoom400'
  @scale: -> 4

  @initialize()

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.Actions.Zoom800 extends ZoomToScale
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.Actions.Zoom800'
  @scale: -> 8

  @initialize()

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.Actions.Zoom1600 extends ZoomToScale
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.Actions.Zoom1600'
  @scale: -> 16

  @initialize()

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.Actions.Zoom3200 extends ZoomToScale
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.Actions.Zoom3200'
  @scale: -> 32

  @initialize()
