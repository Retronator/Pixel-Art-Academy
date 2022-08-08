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
    @canvasPositionOffset = new ReactiveField x: 0, y: 0
  
  onCreated: ->
    super arguments...
    
    # Reactively add views.
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
          return unless @interface.isCreated()
          applicationAreaData = @interface.currentApplicationAreaData()
          views = applicationAreaData.get 'views'
          existingViewIndex = _.findIndex views, (view) => view.type is viewId
          
          anyToolIsAvailable = _.some toolKeys, (toolKey) => @toolIsAvailable toolKey
          
          if anyToolIsAvailable
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

    # Reset canvas offset when entering the editor
    @autorun (computation) =>
      return unless @active()
  
      @canvasPositionOffset x: 0, y: 0
  
    # Invert grid color for assets with dark backgrounds.
    @autorun (computation) =>
      return unless @interface.isCreated()
      return unless fileData = @interface.getActiveFileData()
      
      invert = false
  
      if backgroundColor = @displayedAsset()?.backgroundColor?()
        invert = backgroundColor.r < 0.5 and backgroundColor.g < 0.5 and backgroundColor.b < 0.5
      
      Tracker.nonreactive => fileData.child('pixelGrid').set 'invertColor', invert
  
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
  
  toolIsAvailable: (toolKey) ->
    return true unless availableKeys = @displayedAsset()?.availableToolKeys?()
    toolKey in availableKeys

  ###
# Initialize components.
@sprite new LOI.Assets.Engine.Sprite
  spriteData: @spriteData

@pixelCanvas new LOI.Assets.Components.PixelCanvas
  initialCameraScale: 0
  activeTool: @activeTool
  cameraInput: false
  grid: => @drawingActive()
  gridInvertColor: =>
    displayedAsset = @displayedAsset()
    return unless backgroundColor = displayedAsset?.backgroundColor?()
    backgroundColor.r < 0.5 and backgroundColor.g < 0.5 and backgroundColor.b < 0.5

  cursor: => @drawingActive()
  canvasSize: => @spriteData()?.bounds
  drawComponents: =>
    components = [
      @sprite()
    ]

    # Add any custom components that are visible all the time.
    displayedAsset = @displayedAsset()

    if assetComponents = displayedAsset?.drawComponents?()
      components.push assetComponents...
      
    # Add components visible only in the editor.
    if @active()
      if assetComponents = displayedAsset?.editorDrawComponents?()
        components.push assetComponents...

    # Set extra info to components
    backgroundColor = displayedAsset?.backgroundColor?()
    backgroundColor ?= LOI.Assets.Palette.defaultPalette().color LOI.Assets.Palette.Atari2600.hues.gray, 7

    for component in components
      component.options.backgroundColor = backgroundColor

    components

@palette new @constructor.Palette
  paletteId: @paletteId
  paletteData: @paletteData
  theme: @

@references new @constructor.References
  assetId: @spriteId
  documentClass: LOI.Assets.Sprite
  editorActive: => @active()
  assetOptions: =>
    @displayedAsset()?.editorOptions?()?.references

@pico8 new @constructor.Pico8
  asset: @activeAsset

# Automatically enter focused mode when PICO-8 is active.
@autorun (computation) =>
  @focusedMode @pico8().active()

# Automatically deactivate PICO-8 when exiting focused mode.
@autorun (computation) =>
  @pico8().active false unless @focusedMode()
  
# Create tools.
@toolClasses =
  "#{PAA.Practice.Software.Tools.ToolKeys.Pencil}": LOI.Assets.Components.Tools.Pencil
  "#{PAA.Practice.Software.Tools.ToolKeys.Eraser}": LOI.Assets.Components.Tools.Eraser
  "#{PAA.Practice.Software.Tools.ToolKeys.ColorFill}": LOI.Assets.Components.Tools.ColorFill
  "#{PAA.Practice.Software.Tools.ToolKeys.ColorPicker}": LOI.Assets.Components.Tools.ColorPicker
  "#{PAA.Practice.Software.Tools.ToolKeys.MoveCanvas}": @constructor.Tools.MoveCanvas
  "#{PAA.Practice.Software.Tools.ToolKeys.Undo}": LOI.Assets.Components.Tools.Undo
  "#{PAA.Practice.Software.Tools.ToolKeys.Redo}": LOI.Assets.Components.Tools.Redo

@toolInstances = {}

for toolKey, toolClass of @toolClasses
  @toolInstances[toolKey] = new toolClass
    editor: => @

# Allow the asset to control which tools are available.
@autorun (computation) =>
  activeAsset = @activeAsset()

  if availableToolKeys = activeAsset?.availableToolKeys?()
    tools = _.at @toolInstances, availableToolKeys
    @tools _.without tools, undefined

  else
    @tools _.values @toolInstances



# Deactivate active tool when closing the editor.
@autorun (computation) =>
  if @active()
    unless @activeTool()
      # Make sure the last active tool is still allowed.
      if @_lastActiveTool in @tools()
        @toolbox().activateTool @_lastActiveTool

  else
    if activeTool = @activeTool()
      @_lastActiveTool = activeTool
      @toolbox().deactivateTool()

# Keep pixel canvas centered on the sprite.
@autorun (computation) =>
  return unless spriteData = @spriteData()

  @pixelCanvas().camera().origin
    x: spriteData.bounds.width / 2
    y: spriteData.bounds.height / 2

###
  
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

        ###
    $(document).on 'keydown.pixelartacademy-pixelboy-apps-drawing-editor-desktop', (event) =>
      return unless @active()
      
      switch event.which
        when AC.Keys.f
          # Toggle focused mode.
          @focusedMode not @focusedMode()

        else
          return
  
###

  onDestroyed: ->
    super arguments...

    ###
    $(document).off('.pixelartacademy-pixelboy-apps-drawing-editor-desktop')
    
    @pico8().device?.stop()
  
###

  ###
  onBackButton: ->
    # Turn off focused mode on back button.
    return super(arguments...) unless @focusedMode()
    
    
    @focusedMode false

    # Inform that we've handled the back button.
    true
  ###
  
  defaultInterfaceData: ->
    activeToolId = LOI.Assets.Editor.Tools.Arrow.id()
  
    components =
      "#{_.snakeCase LOI.Assets.SpriteEditor.Tools.Pencil.id()}":
        fractionalPerfectLines: true
        drawPreview: true
    
      "#{_.snakeCase LOI.Assets.SpriteEditor.Helpers.Brush.id()}":
        round: true
        
      "#{_.snakeCase PAA.PixelBoy.Apps.Drawing.Editor.Desktop.PixelCanvas.id()}":
        fixedCanvasSize: true
        components: [PAA.PixelBoy.Apps.Drawing.Editor.PixelCanvasComponents.id()]
        
      "#{_.snakeCase LOI.Assets.SpriteEditor.Helpers.ZoomLevels.id()}":
        [50, 100, 200, 300, 400, 600, 800, 1200, 1600]
      
    views = [
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
          "#{PAA.PixelBoy.Apps.Drawing.Editor.Desktop.Tools.MoveCanvas.id()}": key: AC.Keys.h, holdKey: AC.Keys.space
          
          "#{LOI.Assets.Editor.Actions.Undo.id()}": commandOrControl: true, key: AC.Keys.z
          "#{LOI.Assets.Editor.Actions.Redo.id()}": if isMacOS then command: true, shift: true, key: AC.Keys.z else control: true, key: AC.Keys.y
          "#{LOI.Assets.SpriteEditor.Actions.ZoomIn.id()}": [{key: AC.Keys.equalSign, keyLabel: '+'}, {commandOrControl: true, key: AC.Keys.equalSign}, {key: AC.Keys.numPlus}]
          "#{LOI.Assets.SpriteEditor.Actions.ZoomOut.id()}": [{key: AC.Keys.dash}, {commandOrControl: true, key: AC.Keys.dash}, {key: AC.Keys.numMinus}]

    # Return combined interface data.
    {activeToolId, components, layouts, shortcuts}
    
  drawingActiveClass: ->
    'drawing-active' if @drawingActive()
    
  focusedModeClass: ->
    'focused-mode' if @focusedMode()
  
  draggingClass: ->
    return unless @interface.isCreated()
    moveTool = @interface.getOperator PAA.PixelBoy.Apps.Drawing.Editor.Desktop.Tools.MoveCanvas.id()
    references = @interface.allChildComponentsOfType(PAA.PixelBoy.Apps.Drawing.Editor.Desktop.References)[0]

    'dragging' if _.some [
      moveTool.moving()
      references?.displayComponent.dragging()
      #@pico8().dragging()
    ]

  resizingDirectionClass: ->
    ###
    @references().resizingReference()?.resizingDirectionClass()
  
###

  pico8Enabled: ->
    @displayedAsset()?.project?.pico8Cartridge?
