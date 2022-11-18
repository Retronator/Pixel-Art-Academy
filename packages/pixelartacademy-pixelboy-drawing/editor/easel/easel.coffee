AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

class PAA.PixelBoy.Apps.Drawing.Editor.Easel extends PAA.PixelBoy.Apps.Drawing.Editor
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Drawing.Editor.Easel'
  @version: -> '0.1.0-wip'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Easel"

  @styleClass: -> 'editor-easel'

  @initialize()
  
  @DisplayModes =
    Normal: 'Normal'
    ZoomedIn: 'ZoomedIn'
    Focused: 'Focused'

  constructor: ->
    super arguments...
    
    @displayMode = new ReactiveField @constructor.DisplayModes.Normal
    
    @_lastZoomedInScale = 1
    @_lastZoomedInOrigin = x: 0, y: 0
  
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

    viewsToolRequirements = {}

    for viewId, toolKeys of viewsToolRequirements
      do (viewId, toolKeys) =>
        toolKeys = [toolKeys] unless _.isArray toolKeys

        @autorun (computation) =>
          anyToolIsAvailable = _.some toolKeys, (toolKey) => @toolIsAvailable toolKey

          handleView viewId, anyToolIsAvailable
  
    # Reactively add tools and actions.
    toolRequirements =
      "#{PAA.PixelBoy.Apps.Drawing.Editor.Easel.Tools.Brush.Square.id()}": PAA.Practice.Software.Tools.ToolKeys.Brush
      "#{PAA.PixelBoy.Apps.Drawing.Editor.Easel.Tools.Brush.Pixel.id()}": PAA.Practice.Software.Tools.ToolKeys.Pencil
      "#{PAA.PixelBoy.Apps.Drawing.Editor.Easel.Tools.Brush.Round.id()}": PAA.Practice.Software.Tools.ToolKeys.Brush
      "#{LOI.Assets.SpriteEditor.Tools.ColorFill.id()}": PAA.Practice.Software.Tools.ToolKeys.ColorFill
      "#{LOI.Assets.SpriteEditor.Tools.ColorPicker.id()}": PAA.Practice.Software.Tools.ToolKeys.ColorPicker
      "#{PAA.PixelBoy.Apps.Drawing.Editor.Tools.MoveCanvas.id()}": PAA.Practice.Software.Tools.ToolKeys.MoveCanvas
  
    actionRequirements =
      "#{PAA.PixelBoy.Apps.Drawing.Editor.Easel.Actions.DisplayMode.id()}": PAA.Practice.Software.Tools.ToolKeys.Zoom
      "#{PAA.PixelBoy.Apps.Drawing.Editor.Easel.Actions.ClearPaint.id()}": PAA.Practice.Software.Tools.ToolKeys.ClearColor
  
    @autorun (computation) =>
      return unless @interface.isCreated()
      applicationAreaData = @interface.currentApplicationAreaData()
      views = applicationAreaData.get 'views'
      layoutViewIndex = _.findIndex views, (view) => view.type is PAA.PixelBoy.Apps.Drawing.Editor.Easel.Layout.id()
      
      tools = [
        LOI.Assets.Editor.Tools.Arrow.id()
      ]
      
      tools.push toolId for toolId, toolKey of toolRequirements when @toolIsAvailable toolKey
      actions = (actionId for actionId, toolKey of actionRequirements when @toolIsAvailable toolKey)
  
      Tracker.nonreactive =>
        applicationAreaData.set "views.#{layoutViewIndex}.toolbox.tools", tools
        applicationAreaData.set "views.#{layoutViewIndex}.actions", actions
        
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
  
    # Reset camera when entering the editor. Make sure the default camera info is available.
    @_defaultCameraInfoAvailable = new ComputedField =>
      # Wait until the clipboard is created so that we have the correct scale.
      return false unless @activeAsset()?.clipboardComponent.assetSize?()?
    
      # Wait until the default camera origin is available.
      layoutView = @getLayoutView()
      return false unless layoutView.defaultCameraOrigin()
    
      true
  
    @autorun (computation) =>
      return unless @interface.isCreated()
      return unless @active()
      return unless @_defaultCameraInfoAvailable()
    
      Tracker.nonreactive => @_applyDefaultCamera()
      
    # Automatically enter zoomed-in mode when moving the canvas
    # in normal mode and the layout can't compensate for its position.
    @autorun (computation) =>
      return unless @interface.isCreated()
      return unless @displayMode() is @constructor.DisplayModes.Normal
    
      moveTool = @interface.getOperator PAA.PixelBoy.Apps.Drawing.Editor.Tools.MoveCanvas.id()
      return unless moveTool.moving()
    
      layoutView = @getLayoutView()
      return unless layoutView.frameOffset().outOfBounds
  
      # Enter zoomed-in mode while preserving current scale.
      @enterZoomedInDisplayMode false
  
    # Automatically enter zoomed-in mode if camera scale doesn't match the default scale.
    @autorun (computation) =>
      return unless @interface.isCreated()
      return unless @displayMode() is @constructor.DisplayModes.Normal
      return unless clipboardAssetSize = @displayedAsset()?.clipboardComponent.assetSize?()
  
      # Depend on camera scale changes.
      pixelCanvas = @getPixelCanvas()
      pixelCanvas.camera().scale()
  
      # Give the camera scale a chance to update when display modes are being changed.
      Tracker.afterFlush =>
        scale = pixelCanvas.camera().scale()
        return if scale is clipboardAssetSize.scale
      
        # Enter zoomed-in mode while preserving current scale.
        @enterZoomedInDisplayMode false

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
    
  getLayoutView: ->
    @_getView PAA.PixelBoy.Apps.Drawing.Editor.Easel.Layout
    
  getPixelCanvas: ->
    @_getView PAA.PixelBoy.Apps.Drawing.Editor.Easel.PixelCanvas
    
  cycleDisplayMode: ->
    displayMode = @displayMode()
  
    switch displayMode
      when @constructor.DisplayModes.Normal
        @enterZoomedInDisplayMode()
        
      when @constructor.DisplayModes.ZoomedIn
        @enterFocusedDisplayMode()
      
      when @constructor.DisplayModes.Focused
        @enterNormalDisplayMode()
        
  enterNormalDisplayMode: ->
    @_saveLastZoomedInCamera()
    @_applyDefaultCamera()
    @displayMode @constructor.DisplayModes.Normal
    
  enterZoomedInDisplayMode: (restoreLastCamera = true) ->
    @_applyLastZoomedInCamera() if @displayMode() is @constructor.DisplayModes.Normal and restoreLastCamera
    @displayMode @constructor.DisplayModes.ZoomedIn
    
  enterFocusedDisplayMode: ->
    @_applyLastZoomedInCamera() if @displayMode() is @constructor.DisplayModes.Normal
    @displayMode @constructor.DisplayModes.Focused
    
  _applyLastZoomedInCamera: ->
    pixelCanvas = @getPixelCanvas()
    camera = pixelCanvas.camera()
    camera.setScale @_lastZoomedInScale
    camera.setOrigin @_lastZoomedInOrigin

  _saveLastZoomedInCamera: ->
    pixelCanvas = @getPixelCanvas()
    camera = pixelCanvas.camera()
    @_lastZoomedInScale = camera.scale()
    @_lastZoomedInOrigin = camera.origin()
    
  _applyDefaultCamera: ->
    clipboardAssetSize = @activeAsset().clipboardComponent.assetSize()
    
    # Set the scale to clipboard's calculated scale.
    defaultCameraScale = clipboardAssetSize.scale
    
    # Set the origin to layout's calculated default.
    layoutView = @getLayoutView()
    defaultCameraOrigin = layoutView.defaultCameraOrigin()
  
    # Set the camera properties.
    pixelCanvas = @getPixelCanvas()
    camera = pixelCanvas.camera()

    camera.setOrigin defaultCameraOrigin
    camera.setScale defaultCameraScale

  onBackButton: ->
    # Cycle back display modes on back button.
    displayMode = @displayMode()
    return super(arguments...) if displayMode is @constructor.DisplayModes.Normal
  
    if displayMode is @constructor.DisplayModes.ZoomedIn
      @enterNormalDisplayMode()
      
    else
      @enterZoomedInDisplayMode()

    # Inform that we've handled the back button.
    true

  defaultInterfaceData: ->
    activeToolId = LOI.Assets.Editor.Tools.Arrow.id()
  
    components =
      "#{_.snakeCase PAA.PixelBoy.Apps.Drawing.Editor.Easel.PixelCanvas.id()}":
        components: [PAA.PixelBoy.Apps.Drawing.Editor.PixelCanvasComponents.id()]
      
      "#{_.snakeCase LOI.Assets.SpriteEditor.Helpers.Brush.id()}":
        diameter: 5
        round: true
        
    views = [
      type: FM.Menu.id()
      items: [
        LOI.Assets.SpriteEditor.Actions.BrushSizeIncrease.id()
        LOI.Assets.SpriteEditor.Actions.BrushSizeDecrease.id()
        LOI.Assets.SpriteEditor.Actions.ZoomIn.id()
        LOI.Assets.SpriteEditor.Actions.ZoomOut.id()
      ]
    ,
      type: PAA.PixelBoy.Apps.Drawing.Editor.Easel.Layout.id()
      toolbox:
        type: FM.Toolbox.id()
        tools: []
      colorFill:
        type: PAA.PixelBoy.Apps.Drawing.Editor.Easel.ColorFill.id()
    ,
      type: FM.EditorView.id()
      files: @_dummyEditorViewFiles
      editor:
        contentComponentId: PAA.PixelBoy.Apps.Drawing.Editor.Easel.PixelCanvas.id()
    ]

    layouts =
      currentLayoutId: 'main'
      main:
        name: 'Main'
        applicationArea:
          type: FM.MultiView.id()
          views: views
  
    shortcuts = _.defaultsDeep
      default:
        mapping:
          "#{PAA.PixelBoy.Apps.Drawing.Editor.Easel.Tools.Brush.Square.id()}": key: AC.Keys.b
          "#{PAA.PixelBoy.Apps.Drawing.Editor.Easel.Tools.Brush.Pixel.id()}": key: AC.Keys.b
          "#{PAA.PixelBoy.Apps.Drawing.Editor.Easel.Tools.Brush.Round.id()}": key: AC.Keys.b
  
          "#{PAA.PixelBoy.Apps.Drawing.Editor.Easel.Actions.DisplayMode.id()}": key: AC.Keys.f
          "#{LOI.Assets.SpriteEditor.Actions.BrushSizeDecrease.id()}": [{key: AC.Keys.openBracket}, {key: AC.Keys.openBracket, commandOrControl: true}]
          "#{LOI.Assets.SpriteEditor.Actions.BrushSizeIncrease.id()}": [{key: AC.Keys.closeBracket}, {key: AC.Keys.closeBracket, commandOrControl: true}]
    ,
      @getShortcuts()

    # Return combined interface data.
    {activeToolId, components, layouts, shortcuts}
    
  drawingActiveClass: ->
    'drawing-active' if @drawingActive()
    
  displayModeClass: ->
    "#{_.kebabCase @displayMode()}-mode"
  
  draggingClass: ->
    return unless @interface.isCreated()
    moveTool = @interface.getOperator PAA.PixelBoy.Apps.Drawing.Editor.Tools.MoveCanvas.id()
  
    'dragging' if _.some [
      moveTool.moving()
    ]

  toolIsAvailable: (toolKey) ->
    return true unless availableKeys = @displayedAsset()?.availableToolKeys?()
    toolKey in availableKeys

  _getView: (viewClass) ->
    return unless @interface.isCreated()

    @interface.allChildComponentsOfType(viewClass)[0]
