AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

class PAA.PixelPad.Apps.Drawing.Editor.Desktop extends PAA.PixelPad.Apps.Drawing.Editor
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Desktop"

  @styleClass: -> 'editor-desktop'

  @initialize()

  constructor: ->
    super arguments...
    
    @focusedMode = new ReactiveField false
  
  onCreated: ->
    super arguments...
    
    # Reactively add views.
    handleView = (viewId, enabled) =>
      return unless @interface.isCreated()
      applicationAreaData = @interface.currentApplicationAreaData()
      views = applicationAreaData.get 'views'
      existingViewIndex = _.findIndex views, (view) => view.type is viewId

      if enabled
        # Add the view if it's not yet added.
        if existingViewIndex is -1
          view = type: viewId

          views.push view
          Tracker.nonreactive => applicationAreaData.set 'views', views

      else
        # Remove the view if it's there.
        if existingViewIndex > -1
          views.splice existingViewIndex, 1
          Tracker.nonreactive => applicationAreaData.set 'views', views

    viewsToolRequirements =
      "#{PAA.PixelPad.Apps.Drawing.Editor.Desktop.Zoom.id()}": PAA.Practice.Software.Tools.ToolKeys.Zoom
      "#{PAA.PixelPad.Apps.Drawing.Editor.Desktop.Palette.id()}": PAA.Practice.Software.Tools.ToolKeys.ColorSwatches
      "#{PAA.PixelPad.Apps.Drawing.Editor.Desktop.ColorFill.id()}": PAA.Practice.Software.Tools.ToolKeys.ColorFill
      "#{PAA.PixelPad.Apps.Drawing.Editor.Desktop.TestPaper.id()}": [PAA.Practice.Software.Tools.ToolKeys.Pencil, PAA.Practice.Software.Tools.ToolKeys.Eraser, PAA.Practice.Software.Tools.ToolKeys.Undo, PAA.Practice.Software.Tools.ToolKeys.Redo]
      "#{PAA.PixelPad.Apps.Drawing.Editor.Desktop.References.id()}": PAA.Practice.Software.Tools.ToolKeys.References

    for viewId, toolKeys of viewsToolRequirements
      do (viewId, toolKeys) =>
        toolKeys = [toolKeys] unless _.isArray toolKeys

        @autorun (computation) =>
          anyToolIsAvailable = _.some toolKeys, (toolKey) => @toolIsAvailable toolKey

          handleView viewId, anyToolIsAvailable

    @autorun (computation) =>
      pico8Cartridge = @displayedAsset()?.project?.pico8Cartridge?
      handleView PAA.PixelPad.Apps.Drawing.Editor.Desktop.Pico8.id(), pico8Cartridge

    # Reactively add tools and actions.
    toolRequirements =
      "#{LOI.Assets.SpriteEditor.Tools.Pencil.id()}": PAA.Practice.Software.Tools.ToolKeys.Pencil
      "#{LOI.Assets.SpriteEditor.Tools.Eraser.id()}": PAA.Practice.Software.Tools.ToolKeys.Eraser
      "#{LOI.Assets.SpriteEditor.Tools.ColorFill.id()}": PAA.Practice.Software.Tools.ToolKeys.ColorFill
      "#{LOI.Assets.SpriteEditor.Tools.ColorPicker.id()}": PAA.Practice.Software.Tools.ToolKeys.ColorPicker
      "#{@constructor.Tools.MoveCanvas.id()}": PAA.Practice.Software.Tools.ToolKeys.MoveCanvas
      
    @autorun (computation) =>
      return unless @interface.isCreated()
      applicationAreaData = @interface.currentApplicationAreaData()
      views = applicationAreaData.get 'views'
      toolboxViewIndex = _.findIndex views, (view) => view.type is FM.Toolbox.id()
      
      tools = [
        LOI.Assets.Editor.Tools.Arrow.id()
      ]
  
      tools.push toolId for toolId, toolKey of toolRequirements when @toolIsAvailable toolKey
  
      Tracker.nonreactive => applicationAreaData.set "views.#{toolboxViewIndex}.tools", tools
  
    historyActionRequirements =
      "#{LOI.Assets.Editor.Actions.Undo.id()}": PAA.Practice.Software.Tools.ToolKeys.Undo
      "#{LOI.Assets.Editor.Actions.Redo.id()}": PAA.Practice.Software.Tools.ToolKeys.Redo
  
    @autorun (computation) =>
      return unless @interface.isCreated()
      applicationAreaData = @interface.currentApplicationAreaData()
      views = applicationAreaData.get 'views'
      testPaperViewIndex = _.findIndex views, (view) => view.type is PAA.PixelPad.Apps.Drawing.Editor.Desktop.TestPaper.id()
      return unless testPaperViewIndex > -1
  
      actions = (actionId for actionId, toolKey of historyActionRequirements when @toolIsAvailable toolKey)
  
      Tracker.nonreactive => applicationAreaData.set "views.#{testPaperViewIndex}.actions", actions

    zoomActionRequirements =
      "#{LOI.Assets.SpriteEditor.Actions.ZoomIn.id()}": PAA.Practice.Software.Tools.ToolKeys.Zoom
      "#{LOI.Assets.SpriteEditor.Actions.ZoomOut.id()}": PAA.Practice.Software.Tools.ToolKeys.Zoom

    @autorun (computation) =>
      return unless @interface.isCreated()
      applicationAreaData = @interface.currentApplicationAreaData()
      views = applicationAreaData.get 'views'
      zoomViewIndex = _.findIndex views, (view) => view.type is PAA.PixelPad.Apps.Drawing.Editor.Desktop.Zoom.id()
      return unless zoomViewIndex > -1

      actions = (actionId for actionId, toolKey of zoomActionRequirements when @toolIsAvailable toolKey)

      Tracker.nonreactive => applicationAreaData.set "views.#{zoomViewIndex}.actions", actions
  
    # Invert UI colors for assets with dark backgrounds.
    @autorun (computation) =>
      return unless @interface.isCreated()
      return unless fileData = @interface.getActiveFileData()
      
      invert = false
  
      if backgroundColor = @displayedAsset()?.backgroundColor?()
        invert = backgroundColor.r < 0.5 and backgroundColor.g < 0.5 and backgroundColor.b < 0.5
      
      Tracker.nonreactive => fileData.set 'invertUIColors', invert
  
    # Select the first color if no color is set or the color is not available.
    @autorun (computation) =>
      return unless @interface.isCreated()
      @paintHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Paint

      if paletteColor = @paintHelper.paletteColor()
        # We have a palette color. Wait until information about the palette is available.
        return unless palette = @interface.getLoaderForActiveFile()?.palette()

        # Only reset the color if the palette does not contain the current one.
        setFirst = not (palette.ramps[paletteColor.ramp]?.shades[paletteColor.shade])

      else
        # Palette color has not been set yet so we set it automatically.
        setFirst = true

      if setFirst
        Tracker.nonreactive => @paintHelper.setPaletteColor ramp: 0, shade: 0

    # Set zoom levels based on display scale.
    @autorun (computation) =>
      return unless @interface.isCreated()

      zoomLevels = [100, 200, 300, 400, 600, 800, 1200, 1600]
      displayScale = LOI.adventure.interface.display.scale()

      if displayScale % 3 is 0
        zoomLevels = [100 / 3, 200 / 3, zoomLevels...]

      else
        zoomLevels = [50, zoomLevels...]

      # Extend zoom levels down to clipboard scale if necessary.
      if displayedAsset = @displayedAsset()
        if displayedAsset.clipboardComponent.isCreated()
          if clipboardAssetSize = displayedAsset.clipboardComponent.assetSize()
            minimumScale = clipboardAssetSize.scale * 100
            while Math.round(minimumScale) < Math.round(zoomLevels[0])
              zoomLevels.unshift zoomLevels[0] / 2
        
      zoomLevelsHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.ZoomLevels
      Tracker.nonreactive => zoomLevelsHelper zoomLevels

    # Automatically enter focused mode when PICO-8 is active.
    @autorun (computation) =>
      return unless pico8 = @_getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.Pico8

      @focusedMode pico8.active()

    # Automatically deactivate PICO-8 when exiting focused mode.
    @autorun (computation) =>
      return unless pico8 = @_getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.Pico8

      pico8.active false unless @focusedMode()

    # Deactivate active tool when closing the editor and reactivate it when opening if it's still available.
    @autorun (computation) =>
      return unless @interface.isCreated()

      if @active()
        # The editor is opened.
        unless @interface.activeTool()
          # Make sure the last active tool is still allowed.
          if @_lastActiveTool in @interface.tools()
            # Reactivate the last tool.
            Tracker.nonreactive => @interface.activateTool @_lastActiveTool

      else
        # The editor is being closed.
        if activeTool = @interface.activeTool()
          # Remember which tool was used and deactivate it.
          @_lastActiveTool = activeTool
          Tracker.nonreactive => @interface.deactivateTool()
  
  onRendered: ->
    super arguments...

    @autorun =>
      if @active()
        # Add the drawing active class with delay so that the initial transitions still happen slowly.
        Meteor.setTimeout =>
          @drawingActive true
        ,
          1000

      else
        # Immediately remove the drawing active class so that the slow transitions kick in.
        @drawingActive false

  onBackButton: ->
    # Turn off focused mode on back button.
    return super(arguments...) unless @focusedMode()
    
    @focusedMode false

    # Inform that we've handled the back button.
    true

  defaultInterfaceData: ->
    activeToolId = LOI.Assets.Editor.Tools.Arrow.id()
  
    components =
      "#{_.snakeCase PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelCanvas.id()}":
        components: [PAA.PixelPad.Apps.Drawing.Editor.PixelCanvasComponents.id()]
      
    views = [
      type: FM.Menu.id()
      items: [
        PAA.PixelPad.Apps.Drawing.Editor.Desktop.Actions.Focus.id()
      ]
    ,
      type: FM.Toolbox.id()
      tools: []
    ,
      type: FM.EditorView.id()
      files: @_dummyEditorViewFiles
      editor:
        contentComponentId: PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelCanvas.id()
    ]

    layouts =
      currentLayoutId: 'main'
      main:
        name: 'Main'
        applicationArea:
          type: FM.MultiView.id()
          views: views
          
    isMacOS = AM.ShortcutHelper.currentPlatformConvention is AM.ShortcutHelper.PlatformConventions.MacOS
  
    shortcuts =
      currentMappingId: 'default'
      default:
        name: "Default"
        mapping:
          "#{LOI.Assets.SpriteEditor.Tools.ColorFill.id()}": key: AC.Keys.g
          "#{LOI.Assets.SpriteEditor.Tools.ColorPicker.id()}": [{key: AC.Keys.i, holdKey: AC.Keys.alt}, {holdKey: AC.Keys.c}]
          "#{LOI.Assets.SpriteEditor.Tools.Eraser.id()}": key: AC.Keys.e
          "#{LOI.Assets.SpriteEditor.Tools.Pencil.id()}": key: AC.Keys.b
          "#{PAA.PixelPad.Apps.Drawing.Editor.Desktop.Tools.MoveCanvas.id()}": key: AC.Keys.h, holdKey: AC.Keys.space
          
          "#{LOI.Assets.Editor.Actions.Undo.id()}": commandOrControl: true, key: AC.Keys.z
          "#{LOI.Assets.Editor.Actions.Redo.id()}": if isMacOS then command: true, shift: true, key: AC.Keys.z else control: true, key: AC.Keys.y
          "#{LOI.Assets.SpriteEditor.Actions.ZoomIn.id()}": [{key: AC.Keys.equalSign, keyLabel: '+'}, {commandOrControl: true, key: AC.Keys.equalSign}, {key: AC.Keys.numPlus}]
          "#{LOI.Assets.SpriteEditor.Actions.ZoomOut.id()}": [{key: AC.Keys.dash}, {commandOrControl: true, key: AC.Keys.dash}, {key: AC.Keys.numMinus}]
          "#{PAA.PixelPad.Apps.Drawing.Editor.Desktop.Actions.Focus.id()}": key: AC.Keys.f

    # Return combined interface data.
    {activeToolId, components, layouts, shortcuts}
    
  drawingActiveClass: ->
    'drawing-active' if @drawingActive()
    
  focusedModeClass: ->
    'focused-mode' if @focusedMode()
  
  draggingClass: ->
    return unless @interface.isCreated()
    moveTool = @interface.getOperator PAA.PixelPad.Apps.Drawing.Editor.Desktop.Tools.MoveCanvas.id()

    references = @_getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.References
    pico8 = @_getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.Pico8

    'dragging' if _.some [
      moveTool.moving()
      references?.displayComponent.dragging()
      pico8?.dragging()
    ]

  resizingDirectionClass: ->
    return unless references = @_getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.References

    references.displayComponent.resizingReference()?.resizingDirectionClass()

  toolIsAvailable: (toolKey) ->
    return true unless availableKeys = @displayedAsset()?.availableToolKeys?()
    toolKey in availableKeys

  _getView: (viewClass) ->
    return unless @interface.isCreated()

    @interface.allChildComponentsOfType(viewClass)[0]
