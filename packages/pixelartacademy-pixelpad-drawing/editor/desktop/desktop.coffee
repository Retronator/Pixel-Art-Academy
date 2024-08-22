AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
AEc = Artificial.Echo
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
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    variables:
      clipboardDrag: AEc.ValueTypes.Boolean
      clipboardPan: AEc.ValueTypes.Number
      artworkDrag: AEc.ValueTypes.Boolean
      artworkPan: AEc.ValueTypes.Number
      toolsCount: AEc.ValueTypes.Number
      colorFillDrag: AEc.ValueTypes.Boolean
      colorFillPan: AEc.ValueTypes.Number
      colorFillActivate: AEc.ValueTypes.Trigger
      pencilDrag: AEc.ValueTypes.Boolean
      pencilPan: AEc.ValueTypes.Number
      pencilActivate: AEc.ValueTypes.Trigger
      eraserActivate: AEc.ValueTypes.Trigger
      testPaperPan: AEc.ValueTypes.Number
      referencesTrayDrag: AEc.ValueTypes.Boolean
      colorPickerDrag: AEc.ValueTypes.Boolean
      colorPickerPan: AEc.ValueTypes.Number
      colorPickerActivate: AEc.ValueTypes.Trigger
      zoomDrag: AEc.ValueTypes.Boolean
      zoomPan: AEc.ValueTypes.Number
      colorSwatchesDrag: AEc.ValueTypes.Boolean
      colorSwatchesPan: AEc.ValueTypes.Number
      pico8Drag: AEc.ValueTypes.Boolean
      pico8Pan: AEc.ValueTypes.Number
      pixelArtEvaluationDrag: AEc.ValueTypes.Boolean
      pixelArtEvaluationPan: AEc.ValueTypes.Number
      cursorPan: AEc.ValueTypes.Number
  
  @compressPan: (x) ->
    # Since desktop items go out of the screen, we don't want them to clamp to -1 and 1, but smoothly approach it.
    #    2
    # ──────── - 1
    # 1 + e⁻ⁿˣ
    #
    # n is the initial slope factor (2 being about linear at the start).
    n = 2
    
    2 / (1 + Math.exp(-n * x)) - 1
    
  constructor: ->
    super arguments...
    
    @focusedMode = new ReactiveField false
  
  onCreated: ->
    super arguments...
    
    @app = @ancestorComponentOfType Artificial.Base.App
    @app.addComponent @
    
    @_dragTimeLeft = 0
    
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
    
    @autorun (computation) =>
      # Show pixel art evaluation if the document has it.
      documentHasPixelArtEvaluation = @displayedAsset()?.document()?.properties?.pixelArtEvaluation
      
      # Show pixel art evaluation if the asset requires it.
      assetRequiresPixelArtEvaluation = @displayedAsset()?.constructor.pixelArtEvaluation()

      # TODO: Show pixel art evaluation if the asset allows it and it was unlocked.
      
      handleView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation.id(), documentHasPixelArtEvaluation or assetRequiresPixelArtEvaluation

    # Reactively add tools and actions.
    toolRequirements =
      "#{LOI.Assets.SpriteEditor.Tools.Pencil.id()}": PAA.Practice.Software.Tools.ToolKeys.Pencil
      "#{LOI.Assets.SpriteEditor.Tools.HardEraser.id()}": PAA.Practice.Software.Tools.ToolKeys.Eraser
      "#{LOI.Assets.SpriteEditor.Tools.ColorFill.id()}": PAA.Practice.Software.Tools.ToolKeys.ColorFill
      "#{LOI.Assets.SpriteEditor.Tools.ColorPicker.id()}": PAA.Practice.Software.Tools.ToolKeys.ColorPicker
      "#{PAA.PixelPad.Apps.Drawing.Editor.Tools.MoveCanvas.id()}": PAA.Practice.Software.Tools.ToolKeys.MoveCanvas
      
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
      "#{PAA.PixelPad.Apps.Drawing.Editor.Desktop.Actions.ZoomIn.id()}": PAA.Practice.Software.Tools.ToolKeys.Zoom
      "#{PAA.PixelPad.Apps.Drawing.Editor.Desktop.Actions.ZoomOut.id()}": PAA.Practice.Software.Tools.ToolKeys.Zoom

    @autorun (computation) =>
      return unless @interface.isCreated()
      applicationAreaData = @interface.currentApplicationAreaData()
      views = applicationAreaData.get 'views'
      zoomViewIndex = _.findIndex views, (view) => view.type is PAA.PixelPad.Apps.Drawing.Editor.Desktop.Zoom.id()
      return unless zoomViewIndex > -1

      actions = (actionId for actionId, toolKey of zoomActionRequirements when @toolIsAvailable toolKey)

      Tracker.nonreactive => applicationAreaData.set "views.#{zoomViewIndex}.actions", actions
      
    # Listen for tool changes to play activation sounds.
    @_hadStoredTool = false
    
    Tracker.triggerOnDefinedChange =>
      return unless @interface.isCreated()
      @interface.activeToolId()
    ,
      (activeToolId, previousActiveToolId) =>
        # Only sound on switching tools.
        return unless previousActiveToolId
        
        # Don't sound when returning from a stored (hold key) tool.
        if @_hadStoredTool
          @_hadStoredTool = false
          return
        
        # If the tool was selected through the toolbox, the sound should come from the tool position.
        toolbox = @interface.getView FM.Toolbox
        if toolbox?.timeOfLastToolActivation()?.getTime() > Date.now() - 100
          @_prepareUpdatePan()
          @_updatePan()
          
        else
          # Otherwise, sound from the center by resetting the pan variables.
          @audio.colorFillPan 0
          @audio.pencilPan 0
          @audio.colorPickerPan 0
        
        # Trigger tool sound.
        switch activeToolId
          when LOI.Assets.SpriteEditor.Tools.ColorFill.id() then @audio.colorFillActivate()
          when LOI.Assets.SpriteEditor.Tools.ColorPicker.id() then @audio.colorPickerActivate()
          when LOI.Assets.SpriteEditor.Tools.HardEraser.id() then @audio.eraserActivate()
          when LOI.Assets.SpriteEditor.Tools.Pencil.id() then @audio.pencilActivate()
        
        @_hadStoredTool = @interface.storedTool()
  
  onRendered: ->
    super arguments...

    @autorun =>
      # Cancel any previous timeout.
      Meteor.clearTimeout @_activateDrawingTimeout
      
      if @active()
        # Add the drawing active class with delay so that the initial transitions still happen slowly.
        @_activateDrawingTimeout = Meteor.setTimeout =>
          @drawingActive true
        ,
          1000

      else
        # Immediately remove the drawing active class so that the slow transitions kick in.
        @drawingActive false

    # Trigger dragging of present items when the active status changes.
    Tracker.triggerOnDefinedChange =>
      if @active() then true else false
    , (active) =>
      # Tools come in with a half a second delay when entering.
      toolsDelay = if active then 500 else 0

      @_dragPresentItems active, true, toolsDelay
      
    # Trigger dragging of present items (but not the main ones since those don't move) when the focused mode changes.
    Tracker.triggerOnDefinedChange @focusedMode, (focused) =>
      @_dragPresentItems not focused, false, 0
      
    # Update pan for the first time if we're starting directly in the editor.
    @_prepareUpdatePan()
    @_updatePan()

  onDestroyed: ->
    super arguments...
    
    @app.removeComponent @
  
  editorDrawComponents: ->
    providers = [
      @interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
    ]
    
    _.flatten(provider.editorDrawComponents() for provider in providers when provider?)
    
  _dragPresentItems: (visible, mainDrag, toolsDelay) ->
    @_prepareUpdatePan()

    @_dragTimeLeft = 1
    @_mainDrag = mainDrag
    
    if mainDrag
      @_dragEntering = visible
      @audio.artworkDrag visible
      
    @audio.clipboardDrag visible
    
    if editorStyleClasses = @displayedAsset()?.editorStyleClasses()
      if editorStyleClasses.indexOf('hidden-tools') > -1
        @audio.toolsCount 0
        return
    
    Meteor.setTimeout =>
      toolsCount = 0
      
      incrementToolCount = (toolIsAvailable) =>
        toolsCount++ if toolIsAvailable
        toolIsAvailable
        
      displayedAsset = @displayedAsset()
      
      @audio.colorFillDrag visible if incrementToolCount @toolIsAvailable PAA.Practice.Software.Tools.ToolKeys.ColorFill
      @audio.pencilDrag visible if incrementToolCount @toolIsAvailable(PAA.Practice.Software.Tools.ToolKeys.Pencil) or @toolIsAvailable PAA.Practice.Software.Tools.ToolKeys.Eraser
      @audio.referencesTrayDrag visible if incrementToolCount @_getView(PAA.PixelPad.Apps.Drawing.Editor.Desktop.References)?.displayComponent.enabled()
      @audio.colorPickerDrag visible if incrementToolCount @toolIsAvailable(PAA.Practice.Software.Tools.ToolKeys.ColorPicker) and (not editorStyleClasses or editorStyleClasses.indexOf('hidden-color-picker') is -1)
      @audio.zoomDrag visible if incrementToolCount @toolIsAvailable PAA.Practice.Software.Tools.ToolKeys.Zoom
      @audio.colorSwatchesDrag visible if incrementToolCount @toolIsAvailable PAA.Practice.Software.Tools.ToolKeys.ColorSwatches
      @audio.pico8Drag visible if incrementToolCount displayedAsset?.project?.pico8Cartridge?
      @audio.pixelArtEvaluationDrag visible if incrementToolCount displayedAsset?.pixelArtEvaluation and not @_getView(PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation)?.active()
      
      @audio.toolsCount toolsCount
    ,
      toolsDelay

  onBackButton: ->
    # Ask children components if they want to handle the back button.
    for backButtonHandler in @allChildComponentsWith 'onBackButton'
      return true if backButtonHandler.onBackButton()
    
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
        scrollToZoom: animate: duration: 0.2

      "#{_.snakeCase LOI.Assets.SpriteEditor.Helpers.Brush.id()}":
        round: true
      
    views = [
      type: FM.Menu.id()
      items: [
        PAA.PixelPad.Apps.Drawing.Editor.Desktop.Actions.Focus.id()
        LOI.Assets.SpriteEditor.Actions.BrushSizeIncrease.id()
        LOI.Assets.SpriteEditor.Actions.BrushSizeDecrease.id()
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
  
    shortcuts = _.defaultsDeep
      default:
        mapping:
          "#{LOI.Assets.SpriteEditor.Tools.HardEraser.id()}": [
            {key: AC.Keys.e}
            {holdButton: AC.Buttons.secondary}
            {holdButton: AC.Buttons.fifth}
          ]
          
          "#{LOI.Assets.SpriteEditor.Tools.Pencil.id()}": key: AC.Keys.b
          
          "#{PAA.PixelPad.Apps.Drawing.Editor.Desktop.Actions.ZoomIn.id()}": [
            {commandOrControl: true, key: AC.Keys.equalSign}
            {shift: true, commandOrControl: true, key: AC.Keys.equalSign}
            {commandOrControl: true, key: AC.Keys.numPlus}
          ]
          "#{PAA.PixelPad.Apps.Drawing.Editor.Desktop.Actions.ZoomOut.id()}": [
            {commandOrControl: true, key: AC.Keys.dash}
            {commandOrControl: true, key: AC.Keys.numMinus}
          ]
          
          "#{PAA.PixelPad.Apps.Drawing.Editor.Desktop.Actions.Focus.id()}": key: AC.Keys.f
          
          "#{LOI.Assets.SpriteEditor.Actions.BrushSizeIncrease.id()}": [
            {key: AC.Keys.equalSign}
            {shift: true, key: AC.Keys.equalSign}
            {key: AC.Keys.numPlus}
          ]
          "#{LOI.Assets.SpriteEditor.Actions.BrushSizeDecrease.id()}": [
            {key: AC.Keys.dash}
            {key: AC.Keys.numMinus}
          ]
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
    moveTool = @interface.getOperator PAA.PixelPad.Apps.Drawing.Editor.Tools.MoveCanvas.id()

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

    @interface.getView viewClass
    
  update: (appTime) ->
    return unless @_dragTimeLeft > 0
    @_dragTimeLeft -= appTime.elapsedAppTime
    
    if @_mainDrag
      # Account for items being closer together when the editor is closed.
      timeScale = if @_dragEntering then 1 + @_dragTimeLeft else 2 - @_dragTimeLeft
      
    @_updatePan timeScale
    
  _prepareUpdatePan: ->
    @_clipboard = $('.pixelartacademy-pixelpad-apps-drawing-clipboard')[0]
    @_canvas = $('.pixelartacademy-pixelpad-apps-drawing-editor-desktop-pixelcanvas .canvas')[0]
    @_colorFillGlass = $('.pixelartacademy-pixelpad-apps-drawing-editor-desktop-colorfill .glass')[0]
    @_testPaper = $('.pixelartacademy-pixelpad-apps-drawing-editor-desktop-testpaper')[0]
    @_pencil = $('.fatamorgana-toolbox .pencil')[0]
    @_eraser = $('.fatamorgana-toolbox .eraser')[0]
    @_colorPicker = $('.fatamorgana-toolbox .color-picker')[0]
    @_zoom = $('.pixelartacademy-pixelpad-apps-drawing-editor-desktop-zoom')[0]
    @_palette = $('.pixelartacademy-pixelpad-apps-drawing-editor-desktop-palette')[0]
    @_pico8 = $('.pixelartacademy-pixelpad-apps-drawing-editor-desktop-pico8')[0]
    @_pixelArtEvaluation = $('.pixelartacademy-pixelpad-apps-drawing-editor-desktop-pixelartevaluation')[0]
    
  _updatePan: (timeScale = 1) ->
    adjustPan = (pan) => @constructor.compressPan timeScale * pan
    
    @audio.clipboardPan adjustPan AEc.getPanForElement @_clipboard
    @audio.artworkPan adjustPan AEc.getPanForElement @_canvas
    @audio.colorFillPan adjustPan AEc.getPanForElement @_colorFillGlass if @_colorFillGlass
    @audio.testPaperPan adjustPan AEc.getPanForElement @_testPaper if @_testPaper
    @audio.pencilPan adjustPan AEc.getPanForElement pencil if pencil = @_pencil or @_eraser
    @audio.colorPickerPan adjustPan AEc.getPanForElement @_colorPicker if @_colorPicker
    @audio.zoomPan adjustPan AEc.getPanForElement @_zoom if @_zoom
    @audio.colorSwatchesPan adjustPan AEc.getPanForElement @_palette if @_palette
    @audio.pico8Pan adjustPan AEc.getPanForElement @_pico8 if @_pico8
    @audio.pixelArtEvaluationPan adjustPan AEc.getPanForElement @_pixelArtEvaluation if @_pixelArtEvaluation
