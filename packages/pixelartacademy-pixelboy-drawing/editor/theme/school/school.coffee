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

  onCreated: ->
    super

    # Initialize components.
    @sprite new LOI.Assets.Engine.Sprite
      spriteData: @editor.spriteData

    @pixelCanvas new LOI.Assets.Components.PixelCanvas
      initialCameraScale: 8
      activeTool: @activeTool
      cameraInput: false
      grid: true
      mouse: true
      cursor: true
      drawComponents: => [
        @sprite()
      ]

    @navigator new LOI.Assets.Components.Navigator
      camera: @pixelCanvas().camera

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

  onRendered: ->
    super

    @autorun =>
      if @editor.active()
        # Add the drawing active class with delay so that the initial transitions still happen slowly.
        Meteor.setTimeout =>
          @$('.pixelartacademy-pixelboy-apps-drawing-editor-theme-school').addClass('drawing-active')
        ,
          1000

      else
        # Immediately remove the drawing active class so that the slow transitions kick in.
        @$('.pixelartacademy-pixelboy-apps-drawing-editor-theme-school').removeClass('drawing-active')

  spriteStyle: ->
    return unless spriteData = @editor.spriteData()

    scale = @pixelCanvas().camera().scale()

    width = spriteData.bounds.width * scale
    height = spriteData.bounds.height * scale

    # Add one pixel to the size for outer grid line.
    displayScale = LOI.adventure.interface.display.scale()
    pixelInRem = 1 / displayScale

    # After sprite has updated, also resize the pixel canvas.
    Meteor.setTimeout =>
      @pixelCanvas().forceResize()

    width: "#{width + pixelInRem}rem"
    height: "#{height + pixelInRem}rem"
    top: "calc(50% - #{width / 2 + scale}rem)"
    left: "calc(50% - #{height / 2 + scale}rem)"
    borderWidth: "#{scale}rem"
