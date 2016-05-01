AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class PixelArtAcademy.PixelBoy.Apps.Drawing.SpriteCanvas extends AM.Component
  @register 'PixelArtAcademy.PixelBoy.Apps.Drawing.SpriteCanvas'

  constructor: (@drawing) ->
    super

    # Prepare all reactive fields.
    @camera = new ReactiveField null
    @grid = new ReactiveField null
    @mouse = new ReactiveField null
    @cursor = new ReactiveField null
    @sprite = new ReactiveField null

    @$spriteCanvas = new ReactiveField null
    @canvas = new ReactiveField null
    @canvasBounds = new AE.Rectangle()
    @context = new ReactiveField null

    @activeTool = new ReactiveField null

  onCreated: ->
    # Initialize components.
    @camera new @constructor.Camera @, 12
    @grid new @constructor.Grid @
    @mouse new @constructor.Mouse @
    @cursor new @constructor.Cursor @
    @sprite new @constructor.Sprite @

    @tools =
      pencil: new @constructor.Pencil @
      eraser: new @constructor.Eraser @
      colorFill: new @constructor.ColorFill @
      colorPicker: new @constructor.ColorPicker @

    @activeTool @tools.pencil

    # Resize the canvas when sprite size or camera scale changes.
    @autorun =>
      canvas = @canvas()
      return unless canvas

      # Depend on sprite data and scale.
      spriteData = @drawing.spriteData()
      return unless spriteData

      scale = @camera()?.scale()
      return unless scale

      # Resize the back buffer to canvas element size.
      canvas.width = spriteData.bounds.width * scale + 1
      canvas.height = spriteData.bounds.height * scale + 1

      @canvasBounds.width canvas.width
      @canvasBounds.height canvas.height

    # Redraw canvas routine.
    @autorun =>
      return unless @drawing.spriteId()

      context = @context()
      camera = @camera()
      return unless context

      context.setTransform 1, 0, 0, 1, 0, 0
      context.clearRect 0, 0, @canvasBounds.width(), @canvasBounds.height()

      camera.setTransformToCanvas()

      for component in [@sprite(), @grid(), @cursor()]
        continue unless component

        context.save()
        component.draw()
        context.restore()

  onRendered: ->
    # DOM has been rendered, initialize.
    $spriteCanvas = @$('.sprite-canvas')
    @$spriteCanvas $spriteCanvas

    canvas = $spriteCanvas.find('canvas')[0]
    @canvas canvas
    @context canvas.getContext '2d'

    $(window).keydown (event) => @onKeyDown event
    $(window).keyup (event) => @onKeyUp event

  # Helpers

  activeToolClasses: ->
    @activeTool()?.styleClasses()

  spriteCanvasStyle: ->
    padding: "#{1 * @camera()?.scale()}rem"

  contentStyle: ->
    # Add rem units to size to scale with game resolution.
    width: "#{@canvasBounds.width()}rem"
    height: "#{@canvasBounds.height()}rem"

  toolsArray: ->
    tool for name, tool of @tools

  # Events

  events: ->
    super.concat
      'mousedown .sprite-canvas': @onMouseDownSpriteCanvas
      'mouseup .sprite-canvas': @onMouseUpSpriteCanvas
      'mousemove .sprite-canvas': @onMouseMoveSpriteCanvas

  onKeyDown: (event) ->
    switch event.keyCode
      when AC.Keys.n, AC.Keys.b then @activeTool @tools.pencil
      when AC.Keys.e then @activeTool @tools.eraser
      when AC.Keys.g then @activeTool @tools.colorFill
      when AC.Keys.leftCommand, AC.Keys.rightCommand
        @_toolBeforeColorPicker = @activeTool()
        @activeTool @tools.colorPicker

  onKeyUp: (event) ->
    switch event.keyCode
      when AC.Keys.leftCommand, AC.Keys.rightCommand
        @activeTool @_toolBeforeColorPicker

  onMouseDownSpriteCanvas: (event) ->
    @activeTool().mouseDown event

  onMouseUpSpriteCanvas: (event) ->
    @activeTool().mouseUp event

  onMouseMoveSpriteCanvas: (event) ->
    @activeTool().mouseMove event
