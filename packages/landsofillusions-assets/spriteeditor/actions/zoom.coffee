AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class Zoom extends FM.Action
  enabled: -> @interface.activeFileId() and @newZoomLevel()

  constructor: ->
    super arguments...

    @zoomLevels = new ComputedField =>
      navigatorData = @interface.getComponentData LOI.Assets.Components.Navigator
      navigatorData.get('zoomLevels') or [12.5, 25, 50, 66.6, 100, 200, 300, 400, 600, 800, 1200, 1600, 3200]

    @zoomPercentage = new ComputedField =>
      @interface.getEditorForActiveFile()?.camera()?.scale() * 100

  execute: ->
    return unless newZoomLevel = @newZoomLevel()

    @interface.getEditorForActiveFile()?.camera()?.setScale newZoomLevel / 100

class LOI.Assets.SpriteEditor.Actions.ZoomIn extends Zoom
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.ZoomIn'
  @displayName: -> "Zoom in"

  @initialize()

  newZoomLevel: ->
    percentage = @zoomPercentage()

    for zoomLevel in @zoomLevels()
      if zoomLevel > percentage
        return zoomLevel

    null

class LOI.Assets.SpriteEditor.Actions.ZoomOut extends Zoom
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Actions.ZoomOut'
  @displayName: -> "Zoom out"

  @initialize()

  newZoomLevel: ->
    percentage = @zoomPercentage()

    for zoomLevel in @zoomLevels() by -1
      if zoomLevel < percentage
        return zoomLevel

    null
