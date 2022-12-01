AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

class PAA.PixelBoy.Apps.Drawing.Editor.Desktop extends PAA.PixelBoy.Apps.Drawing.Editor
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Drawing.Editor.Desktop'
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
      "#{PAA.PixelBoy.Apps.Drawing.Editor.Desktop.Zoom.id()}": PAA.Practice.Software.Tools.ToolKeys.Zoom
      "#{PAA.PixelBoy.Apps.Drawing.Editor.Desktop.Palette.id()}": PAA.Practice.Software.Tools.ToolKeys.ColorSwatches
      "#{PAA.PixelBoy.Apps.Drawing.Editor.Desktop.ColorFill.id()}": PAA.Practice.Software.Tools.ToolKeys.ColorFill
      "#{PAA.PixelBoy.Apps.Drawing.Editor.Desktop.TestPaper.id()}": [PAA.Practice.Software.Tools.ToolKeys.Pencil, PAA.Practice.Software.Tools.ToolKeys.Eraser, PAA.Practice.Software.Tools.ToolKeys.Undo, PAA.Practice.Software.Tools.ToolKeys.Redo]
      "#{PAA.PixelBoy.Apps.Drawing.Editor.Desktop.References.id()}": PAA.Practice.Software.Tools.ToolKeys.References

    for viewId, toolKeys of viewsToolRequirements
      do (viewId, toolKeys) =>
        toolKeys = [toolKeys] unless _.isArray toolKeys

        @autorun (computation) =>
          anyToolIsAvailable = _.some toolKeys, (toolKey) => @toolIsAvailable toolKey

          handleView viewId, anyToolIsAvailable

    @autorun (computation) =>
      pico8Cartridge = @displayedAsset()?.project?.pico8Cartridge?
      handleView PAA.PixelBoy.Apps.Drawing.Editor.Desktop.Pico8.id(), pico8Cartridge

    # Reactively add tools and actions.
    toolRequirements =
      "#{LOI.Assets.SpriteEditor.Tools.Pencil.id()}": PAA.Practice.Software.Tools.ToolKeys.Pencil
      "#{LOI.Assets.SpriteEditor.Tools.HardEraser.id()}": PAA.Practice.Software.Tools.ToolKeys.Eraser
      "#{LOI.Assets.SpriteEditor.Tools.ColorFill.id()}": PAA.Practice.Software.Tools.ToolKeys.ColorFill
      "#{LOI.Assets.SpriteEditor.Tools.ColorPicker.id()}": PAA.Practice.Software.Tools.ToolKeys.ColorPicker
      "#{PAA.PixelBoy.Apps.Drawing.Editor.Tools.MoveCanvas.id()}": PAA.Practice.Software.Tools.ToolKeys.MoveCanvas
      
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
      testPaperViewIndex = _.findIndex views, (view) => view.type is PAA.PixelBoy.Apps.Drawing.Editor.Desktop.TestPaper.id()
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
      zoomViewIndex = _.findIndex views, (view) => view.type is PAA.PixelBoy.Apps.Drawing.Editor.Desktop.Zoom.id()
      return unless zoomViewIndex > -1

      actions = (actionId for actionId, toolKey of zoomActionRequirements when @toolIsAvailable toolKey)

      Tracker.nonreactive => applicationAreaData.set "views.#{zoomViewIndex}.actions", actions

    # Automatically enter focused mode when PICO-8 is active.
    @autorun (computation) =>
      return unless pico8 = @_getView PAA.PixelBoy.Apps.Drawing.Editor.Desktop.Pico8

      @focusedMode pico8.active()

    # Automatically deactivate PICO-8 when exiting focused mode.
    @autorun (computation) =>
      return unless pico8 = @_getView PAA.PixelBoy.Apps.Drawing.Editor.Desktop.Pico8

      pico8.active false unless @focusedMode()
  
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
      "#{_.snakeCase PAA.PixelBoy.Apps.Drawing.Editor.Desktop.PixelCanvas.id()}":
        components: [PAA.PixelBoy.Apps.Drawing.Editor.PixelCanvasComponents.id()]
      
    views = [
      type: FM.Menu.id()
      items: [
        PAA.PixelBoy.Apps.Drawing.Editor.Desktop.Actions.Focus.id()
      ]
    ,
      type: FM.Toolbox.id()
      tools: []
    ,
      type: FM.EditorView.id()
      files: @_dummyEditorViewFiles
      editor:
        contentComponentId: PAA.PixelBoy.Apps.Drawing.Editor.Desktop.PixelCanvas.id()
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
          "#{LOI.Assets.SpriteEditor.Tools.HardEraser.id()}": key: AC.Keys.e
          "#{LOI.Assets.SpriteEditor.Tools.Pencil.id()}": key: AC.Keys.b
          
          "#{PAA.PixelBoy.Apps.Drawing.Editor.Desktop.Actions.Focus.id()}": key: AC.Keys.f
    ,
      @getShortcuts()

    # Return combined interface data.
    {activeToolId, components, layouts, shortcuts}
    
  drawingActiveClass: ->
    'drawing-active' if @drawingActive()
    
  focusedModeClass: ->
    'focused-mode' if @focusedMode()
  
  draggingClass: ->
    return unless @interface.isCreated()
    moveTool = @interface.getOperator PAA.PixelBoy.Apps.Drawing.Editor.Tools.MoveCanvas.id()

    references = @_getView PAA.PixelBoy.Apps.Drawing.Editor.Desktop.References
    pico8 = @_getView PAA.PixelBoy.Apps.Drawing.Editor.Desktop.Pico8

    'dragging' if _.some [
      moveTool.moving()
      references?.displayComponent.dragging()
      pico8?.dragging()
    ]

  resizingDirectionClass: ->
    return unless references = @_getView PAA.PixelBoy.Apps.Drawing.Editor.Desktop.References

    references.displayComponent.resizingReference()?.resizingDirectionClass()

  toolIsAvailable: (toolKey) ->
    return true unless availableKeys = @displayedAsset()?.availableToolKeys?()
    toolKey in availableKeys

  _getView: (viewClass) ->
    return unless @interface.isCreated()

    @interface.allChildComponentsOfType(viewClass)[0]
