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

        assetData = @editor.drawing.portfolio().displayedAsset()

        # Add any custom components that are visible all the time.
        if assetComponents = assetData?.asset.drawComponents?()
          components.push assetComponents...
          
        # Add components visible only in the editor.
        if @editor.active()
          if assetComponents = assetData?.asset.editorDrawComponents?()
            components.push assetComponents...

        components

    @navigator new LOI.Assets.Components.Navigator
      camera: @pixelCanvas().camera
      zoomLevels: [100, 200, 300, 400, 600, 800, 1200, 1600]

    @palette new @constructor.Palette
      paletteId: @paletteId
      theme: @

    @toolbox new LOI.Assets.Components.Toolbox
      tools: @tools
      activeTool: @activeTool
      actions: @actions
      
    # Create tools.
    toolClasses = [
      LOI.Assets.SpriteEditor.Tools.Pencil
      LOI.Assets.SpriteEditor.Tools.Eraser
      LOI.Assets.SpriteEditor.Tools.ColorFill
      LOI.Assets.SpriteEditor.Tools.ColorPicker
    ]

    # We need to forward editor's sprite data as the tools will expect it.
    @spriteData = @editor.spriteData

    tools = for toolClass in toolClasses
      new toolClass
        editor: => @
          
    @tools tools

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

      # Dictate sprite scale when asset is on clipboard and when setting for the first time.
      defaultScale = assetData.scale()

      unless @editor.active() and assetData.asset is @_previousDisplayedAsset and defaultScale is @_previousDefaultScale
        # Asset in the clipboard should be about 150% bigger than portfolio.
        scale = Math.floor assetData.scale() * 1.5

        camera.setScale scale

      @_previousDisplayedAsset = assetData.asset
      @_previousDefaultScale = defaultScale

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

    width = spriteData.bounds.width * scale
    height = spriteData.bounds.height * scale

    # Add one pixel to the size for outer grid line.
    displayScale = LOI.adventure.interface.display.scale()
    pixelInRem = 1 / displayScale

    if @editor.active()
      # We need to be in the middle of the table.
      left = "calc(50% - #{width / 2 + scale}rem)"
      top = "calc(50% - #{height / 2 + scale}rem)"

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
    borderWidth: "#{scale}rem"
