AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Drawing.Editor.Theme.School extends PAA.PixelBoy.Apps.Drawing.Editor.Theme
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Drawing.Editor.Theme.School'
  @register @id()

  @styleClass: -> 'theme-school'

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
      LOI.Assets.Sprite.documents.findOne(@editor.spriteId(),
        fields:
          palette: 1
      )?.palette?._id

    @activeTool = new ReactiveField null

    @drawingActive = new ReactiveField false

  onCreated: ->
    super

    @activeAsset = new ComputedField =>
      @editor.drawing.portfolio().activeAsset()?.asset

    @displayedAsset = new ComputedField =>
      @editor.drawing.portfolio().displayedAsset()?.asset

    # Initialize components.
    @sprite new LOI.Assets.Engine.Sprite
      spriteData: @editor.spriteData

    @pixelCanvas new LOI.Assets.Components.PixelCanvas
      initialCameraScale: 0
      activeTool: @activeTool
      cameraInput: false
      grid: => @drawingActive()
      cursor: => @drawingActive()
      canvasSize: => @editor.spriteData()?.bounds
      drawComponents: =>
        components = [
          @sprite()
        ]

        # Add any custom components that are visible all the time.
        displayedAsset = @displayedAsset()

        if assetComponents = displayedAsset?.drawComponents?()
          components.push assetComponents...
          
        # Add components visible only in the editor.
        if @editor.active()
          if assetComponents = displayedAsset?.editorDrawComponents?()
            components.push assetComponents...

        # Set extra info to components
        backgroundColor = LOI.Assets.Palette.defaultPalette().ramps[LOI.Assets.Palette.Atari2600.hues.grey].shades[7]

        for component in components
          component.options.backgroundColor = backgroundColor

        components

    @navigator new LOI.Assets.Components.Navigator
      camera: @pixelCanvas().camera
      zoomLevels: [100, 200, 300, 400, 600, 800, 1200, 1600]

    @palette new @constructor.Palette
      paletteId: @paletteId
      theme: @

    @references new @constructor.References
      assetId: @editor.spriteId
      documentClass: LOI.Assets.Sprite
      editorActive: @editor.active
      assetOptions: =>
        @displayedAsset()?.editorOptions()?.references

    @pico8 new @constructor.Pico8
      asset: @activeAsset

    @toolbox new LOI.Assets.Components.Toolbox
      tools: @tools
      activeTool: @activeTool
      actions: @actions
      
    # Create tools.
    @toolClasses =
      "#{PAA.Practice.Software.Tools.ToolKeys.Pencil}": LOI.Assets.SpriteEditor.Tools.Pencil
      "#{PAA.Practice.Software.Tools.ToolKeys.Eraser}": LOI.Assets.SpriteEditor.Tools.Eraser
      "#{PAA.Practice.Software.Tools.ToolKeys.ColorFill}": LOI.Assets.SpriteEditor.Tools.ColorFill
      "#{PAA.Practice.Software.Tools.ToolKeys.ColorPicker}": LOI.Assets.SpriteEditor.Tools.ColorPicker

    # We need to provide (editor's) sprite data as the tools will expect it (since they think we are the editor class).
    @spriteData = @editor.spriteData

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
      if @editor.active()
        unless @activeTool()
          # Make sure the last active tool is still allowed.
          if @_lastActiveTool in @tools()
            @activeTool @_lastActiveTool

      else
        if activeTool = @activeTool()
          @_lastActiveTool = activeTool
          @activeTool null

    # Select first color if no color is set.
    @autorun (computation) =>
      palette = @palette()

      palette.setColor 0, 0 unless palette.currentColor()

    # Keep pixel canvas centered on the sprite.
    @autorun (computation) =>
      return unless spriteData = @editor.spriteData()

      @pixelCanvas().camera().origin
        x: spriteData.bounds.width / 2
        y: spriteData.bounds.height / 2

    # Allow triggering sprite style change.
    @spriteStyleChangeDependency = new Tracker.Dependency

    # Do updates when asset changes.
    @autorun (computation) =>
      @editor.drawing.portfolio().displayedAsset()

      # Trigger sprite style change after delay. We need this delay to allow for asset data in the
      # clipboard to update, which will change the position of the sprite when attached to the clipboard.
      Meteor.setTimeout => @spriteStyleChangeDependency.changed()

    # Update sprite scale.
    @autorun (computation) =>
      return unless camera = @pixelCanvas().camera()
      return unless assetData = @editor.drawing.portfolio().displayedAsset()
      return unless clipboardSpriteSize = @editor.drawing.clipboard().spriteSize()

      # Dictate sprite scale when asset is on clipboard and when setting for the first time.
      clipboardSpriteScale = clipboardSpriteSize.scale

      unless @editor.active() and assetData.asset is @_previousDisplayedAsset and clipboardSpriteScale is @_previousClipboardSpriteScale
        camera.setScale clipboardSpriteScale

      @_previousDisplayedAsset = assetData.asset
      @_previousClipboardSpriteScale = clipboardSpriteScale

  onRendered: ->
    super

    @autorun =>
      if @editor.active()
        # Add the drawing active class with delay so that the initial transitions still happen slowly.
        Meteor.setTimeout =>
          @drawingActive true
        ,
          1000

      else
        # Immediately remove the drawing active class so that the slow transitions kick in.
        @drawingActive false
        
  drawingActiveClass: ->
    'drawing-active' if @drawingActive()

  toolClass: ->
    return unless tool = @activeTool()

    toolClass = _.kebabCase tool.name
    extraToolClass = tool.toolClass?()

    [toolClass, extraToolClass].join ' '

  draggingClass: ->
    'dragging' if @references().dragging()

  resizingDirectionClass: ->
    @references().resizingReference()?.resizingDirectionClass()

  spriteStyle: ->
    # Allow to be updated externally.
    @spriteStyleChangeDependency.depend()

    # If nothing else, we should move the sprite off screen.
    offScreenStyle = top: '-150rem'

    # Wait for clipboard to be rendered.
    return offScreenStyle unless @editor.drawing.clipboard().isRendered()

    # If we don't have size data, don't return anything so transition will start form first value.
    return offScreenStyle unless spriteData = @editor.spriteData()
    return offScreenStyle unless scale = @pixelCanvas()?.camera()?.scale()
    return offScreenStyle unless clipboardSpriteSize = @editor.drawing.clipboard().spriteSize()

    width = spriteData.bounds.width * scale
    height = spriteData.bounds.height * scale

    # Add one pixel to the size for outer grid line.
    displayScale = LOI.adventure.interface.display.scale()
    pixelInRem = 1 / displayScale

    # Resize the border proportionally to its clipboard size
    borderWidth = clipboardSpriteSize.borderWidth / clipboardSpriteSize.scale * scale

    if @editor.active()
      # We need to be in the middle of the table.
      left = "calc(50% - #{width / 2 + borderWidth}rem)"
      top = "calc(50% - #{height / 2 + borderWidth}rem)"

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
      activeAsset = @editor.drawing.portfolio().activeAsset()

      positionOrigin.top += $clipboard.height() / 2 if activeAsset
      top = spriteOffset.top - positionOrigin.top

      if activeAsset
        top = "calc(50% + #{top}px)"

      else
        # Clipboard is hidden up, so move the sprite up and relative to top.
        top -= 265 * displayScale

    width: "#{width + pixelInRem}rem"
    height: "#{height + pixelInRem}rem"
    left: left
    top: top
    borderWidth: "#{borderWidth}rem"

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
    return true unless availableKeys = @activeAsset()?.availableToolKeys?()
    toolKey in availableKeys

  pico8Enabled: ->
    @activeAsset()?.project.constructor.pico8GameSlug
