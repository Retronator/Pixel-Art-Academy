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
    Zoomed: 'Zoomed'
    Focused: 'Focused'

  constructor: ->
    super arguments...
    
    @displayMode = new ReactiveField @constructor.DisplayModes.Normal
  
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
      "#{PAA.PixelBoy.Apps.Drawing.Editor.Easel.ColorFill.id()}": PAA.Practice.Software.Tools.ToolKeys.ColorFill

    for viewId, toolKeys of viewsToolRequirements
      do (viewId, toolKeys) =>
        toolKeys = [toolKeys] unless _.isArray toolKeys

        @autorun (computation) =>
          anyToolIsAvailable = _.some toolKeys, (toolKey) => @toolIsAvailable toolKey

          handleView viewId, anyToolIsAvailable

    
  
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
    # Cycle back display modes on back button.
    displayMode = @displayMode()
    return super(arguments...) if displayMode is @constructor.DisplayModes.Normal
  
    @displayMode if displayMode is @constructor.DisplayModes.Zoomed then @constructor.DisplayModes.Normal else @constructor.DisplayModes.Zoomed

    # Inform that we've handled the back button.
    true

  defaultInterfaceData: ->
    activeToolId = LOI.Assets.Editor.Tools.Arrow.id()
  
    components =
      "#{_.snakeCase PAA.PixelBoy.Apps.Drawing.Editor.Easel.PixelCanvas.id()}":
        components: [PAA.PixelBoy.Apps.Drawing.Editor.PixelCanvasComponents.id()]
      
    views = [
      type: FM.Menu.id()
      items: [
        PAA.PixelBoy.Apps.Drawing.Editor.Easel.Actions.DisplayMode.id()
      ]
    ,
      type: PAA.PixelBoy.Apps.Drawing.Editor.Easel.Frame.id()
      toolbox:
        type: FM.Toolbox.id()
        tools: []
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
          
    shortcuts = @getShortcuts()

    # Return combined interface data.
    {activeToolId, components, layouts, shortcuts}
    
  drawingActiveClass: ->
    'drawing-active' if @drawingActive()
    
  displayModeClass: ->
    "#{_.kebabCase @displayMode()}-mode"

  toolIsAvailable: (toolKey) ->
    return true unless availableKeys = @displayedAsset()?.availableToolKeys?()
    toolKey in availableKeys

  _getView: (viewClass) ->
    return unless @interface.isCreated()

    @interface.allChildComponentsOfType(viewClass)[0]
