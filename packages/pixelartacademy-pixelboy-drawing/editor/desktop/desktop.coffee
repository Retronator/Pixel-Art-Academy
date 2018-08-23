AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Drawing.Editor.Desktop extends PAA.PixelBoy.Apps.Drawing.Editor
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Drawing.Editor.Desktop'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Desktop"

  @styleClass: -> 'editor-desktop'

  @initialize()

  constructor: ->
    super

    @sprite = new ReactiveField null
    @pixelCanvas = new ReactiveField null
    @navigator = new ReactiveField null
    @palette = new ReactiveField null
    @tools = new ReactiveField null
    @actions = new ReactiveField null
    @references = new ReactiveField null
    @pico8 = new ReactiveField null
    @toolbox = new ReactiveField null

    @paletteId = new ComputedField =>
      # Minimize reactivity to only palette changes.
      LOI.Assets.Sprite.documents.findOne(@spriteId(),
        fields:
          palette: 1
      )?.palette?._id
      
    @paletteData = new ComputedField =>
      # Minimize reactivity to only custom palette changes.
      LOI.Assets.Sprite.documents.findOne(@spriteId(),
        fields:
          customPalette: 1
      )?.customPalette

    @activeTool = new ReactiveField null

    @drawingActive = new ReactiveField false
    @focusedMode = new ReactiveField false

    @spritePositionOffset = new ReactiveField x: 0, y: 0

  onCreated: ->
    super

    @activeAsset = new ComputedField =>
      @drawing.portfolio().activeAsset()?.asset

    @displayedAsset = new ComputedField =>
      @drawing.portfolio().displayedAsset()?.asset

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
        return unless backgroundColor = displayedAsset?.backgroundColor()
        backgroundColor.r < 0.5 or backgroundColor.g < 0.5 or backgroundColor.b < 0.5

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
        backgroundColor = displayedAsset?.backgroundColor()
        backgroundColor ?= LOI.Assets.Palette.defaultPalette().color LOI.Assets.Palette.Atari2600.hues.grey, 7

        for component in components
          component.options.backgroundColor = backgroundColor

        components

    @navigator new LOI.Assets.Components.Navigator
      camera: @pixelCanvas().camera
      zoomLevels: [50, 100, 200, 300, 400, 600, 800, 1200, 1600]

    @palette new @constructor.Palette
      paletteId: @paletteId
      paletteData: @paletteData
      theme: @

    @references new @constructor.References
      assetId: @spriteId
      documentClass: LOI.Assets.Sprite
      editorActive: @active
      assetOptions: =>
        @displayedAsset()?.editorOptions()?.references

    @pico8 new @constructor.Pico8
      asset: @activeAsset

    # Automatically enter focused mode when PICO-8 is active.
    @autorun (computation) =>
      @focusedMode @pico8().active()

    # Automatically deactivate PICO-8 when exiting focused mode.
    @autorun (computation) =>
      @pico8().active false unless @focusedMode()

    @toolbox new LOI.Assets.Components.Toolbox
      tools: @tools
      activeTool: @activeTool
      actions: @actions
      enabled: @active
      
    # Create tools.
    @toolClasses =
      "#{PAA.Practice.Software.Tools.ToolKeys.Pencil}": LOI.Assets.SpriteEditor.Tools.Pencil
      "#{PAA.Practice.Software.Tools.ToolKeys.Eraser}": LOI.Assets.SpriteEditor.Tools.Eraser
      "#{PAA.Practice.Software.Tools.ToolKeys.ColorFill}": LOI.Assets.SpriteEditor.Tools.ColorFill
      "#{PAA.Practice.Software.Tools.ToolKeys.ColorPicker}": LOI.Assets.SpriteEditor.Tools.ColorPicker
      "#{PAA.Practice.Software.Tools.ToolKeys.MoveCanvas}": @constructor.Tools.MoveCanvas
      "#{PAA.Practice.Software.Tools.ToolKeys.Undo}": LOI.Assets.SpriteEditor.Tools.Undo
      "#{PAA.Practice.Software.Tools.ToolKeys.Redo}": LOI.Assets.SpriteEditor.Tools.Redo

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

    # Select first color if no color is set.
    @autorun (computation) =>
      palette = @palette()

      palette.setColor 0, 0 unless palette.currentColor()

    # Keep pixel canvas centered on the sprite.
    @autorun (computation) =>
      return unless spriteData = @spriteData()

      @pixelCanvas().camera().origin
        x: spriteData.bounds.width / 2
        y: spriteData.bounds.height / 2

    # Allow triggering sprite style change.
    @spriteStyleChangeDependency = new Tracker.Dependency

    # Do updates when asset changes.
    @autorun (computation) =>
      @drawing.portfolio().displayedAsset()

      # Trigger sprite style change after delay. We need this delay to allow for asset data in the
      # clipboard to update, which will change the position of the sprite when attached to the clipboard.
      Meteor.setTimeout => @spriteStyleChangeDependency.changed()

    # Reset sprite offset when entering the editor
    @autorun (computation) =>
      return unless @active()
      
      @spritePositionOffset x: 0, y: 0

    # Update sprite scale.
    @autorun (computation) =>
      return unless camera = @pixelCanvas().camera()
      return unless assetData = @drawing.portfolio().displayedAsset()
      return unless clipboardSpriteSize = @drawing.clipboard().spriteSize()

      # Dictate sprite scale when asset is on clipboard and when setting for the first time.
      clipboardSpriteScale = clipboardSpriteSize.scale

      unless @active() and assetData.asset is @_previousDisplayedAsset and clipboardSpriteScale is @_previousClipboardSpriteScale
        camera.setScale clipboardSpriteScale

      @_previousDisplayedAsset = assetData.asset
      @_previousClipboardSpriteScale = clipboardSpriteScale

  onRendered: ->
    super

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

    $(document).on 'keydown.pixelartacademy-pixelboy-apps-drawing-editor-desktop', (event) =>
      switch event.which
        when AC.Keys.f
          # Toggle focused mode.
          @focusedMode not @focusedMode()

        else
          return

  onDestroyed: ->
    super

    $(document).off('.pixelartacademy-pixelboy-apps-drawing-editor-desktop')
    
    @pico8().device?.stop()

  onBackButton: ->
    # Turn off focused mode on back button.
    return unless @focusedMode()
    @focusedMode false

    # Inform that we've handled the back button.
    true

  drawingActiveClass: ->
    'drawing-active' if @drawingActive()

  focusedModeClass: ->
    'focused-mode' if @focusedMode()

  toolClass: ->
    return unless tool = @activeTool()

    toolClass = _.kebabCase tool.name
    extraToolClass = tool.toolClass?()

    [toolClass, extraToolClass].join ' '

  draggingClass: ->
    'dragging' if _.some [
      @toolInstances[PAA.Practice.Software.Tools.ToolKeys.MoveCanvas].moving()
      @references().dragging()
      @pico8().dragging()
    ]

  resizingDirectionClass: ->
    @references().resizingReference()?.resizingDirectionClass()

  spriteStyle: ->
    # Allow to be updated externally.
    @spriteStyleChangeDependency.depend()

    # If nothing else, we should move the sprite off screen.
    offScreenStyle = top: '-150rem'

    # Wait for clipboard to be rendered.
    return offScreenStyle unless @drawing.clipboard().isRendered()

    # If we don't have size data, don't return anything so transition will start form first value.
    return offScreenStyle unless spriteData = @spriteData()
    return offScreenStyle unless scale = @pixelCanvas()?.camera()?.scale()
    return offScreenStyle unless clipboardSpriteSize = @drawing.clipboard().spriteSize()

    width = spriteData.bounds.width * scale
    height = spriteData.bounds.height * scale

    displayScale = LOI.adventure.interface.display.scale()

    if @drawingActive()
      # Add one pixel to the size for outer grid line.
      pixelInRem = 1 / displayScale

      width += pixelInRem
      height += pixelInRem

    # Resize the border proportionally to its clipboard size
    borderWidth = clipboardSpriteSize.borderWidth / clipboardSpriteSize.scale * scale

    if @active()
      # We need to be in the middle of the table, but allowing for custom offset with dragging.
      offset = @spritePositionOffset()

      # Update offset when scale changes, so that the same pixel will appear in the center.
      if @_previousScale and @_previousScale isnt scale
        offset =
          x: offset.x / @_previousScale * scale
          y: offset.y / @_previousScale * scale

        Tracker.nonreactive => @spritePositionOffset offset

      @_previousScale = scale

      left = "calc(50% - #{width / 2 + borderWidth - offset.x}rem)"
      top = "calc(50% - #{height / 2 + borderWidth - offset.y}rem)"

    else
      $spritePlaceholder = $('.pixelartacademy-pixelboy-apps-drawing-clipboard .sprite-placeholder')
      spriteOffset = $spritePlaceholder.offset()

      $clipboard = $('.pixelartacademy-pixelboy-apps-drawing-clipboard')
      positionOrigin = $clipboard.offset()

      # Make these measurements relative to clipboard center.
      positionOrigin.left += $clipboard.width() / 2
      left = spriteOffset.left - positionOrigin.left
      left = "calc(50% + #{left}px)"

      # Top is relative to center only when we have an active asset.
      activeAsset = @activeAsset()

      positionOrigin.top += $clipboard.height() / 2 if activeAsset
      top = spriteOffset.top - positionOrigin.top

      if activeAsset
        top = "calc(50% + #{top}px)"

      else
        # Clipboard is hidden up, so move the sprite up and relative to top.
        top -= 265 * displayScale

    style =
      width: "#{width}rem"
      height: "#{height}rem"
      left: left
      top: top
      borderWidth: "#{borderWidth}rem"

    if backgroundColor = @displayedAsset()?.backgroundColor()
      style.backgroundColor = "##{backgroundColor.getHexString()}"
      style.borderColor = style.backgroundColor

    style

  testPaperEnabled: ->
    @pencilEnabled() or @eraserEnabled()

  pencilEnabled: ->
    @toolInstances[PAA.Practice.Software.Tools.ToolKeys.Pencil] in @tools()

  eraserEnabled: ->
    @toolInstances[PAA.Practice.Software.Tools.ToolKeys.Eraser] in @tools()

  eraserEnabledClass: ->
    'eraser-enabled' if @eraserEnabled()

  colorFillEnabled: ->
    @toolInstances[PAA.Practice.Software.Tools.ToolKeys.ColorFill] in @tools()

  paletteEnabled: -> @_toolIsAvailable PAA.Practice.Software.Tools.ToolKeys.ColorSwatches

  navigatorEnabled: -> @_toolIsAvailable PAA.Practice.Software.Tools.ToolKeys.Zoom

  referencesEnabled: -> @_toolIsAvailable PAA.Practice.Software.Tools.ToolKeys.References

  _toolIsAvailable: (toolKey) ->
    return true unless availableKeys = @displayedAsset()?.availableToolKeys?()
    toolKey in availableKeys

  pico8Enabled: ->
    @displayedAsset()?.project.pico8Cartridge?
