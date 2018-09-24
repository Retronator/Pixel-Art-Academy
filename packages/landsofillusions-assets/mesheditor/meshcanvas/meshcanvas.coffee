AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas extends AM.Component
  @register 'LandsOfIllusions.Assets.MeshEditor.MeshCanvas'

  constructor: (@options) ->
    super

    _.defaults @options,
      grid: true

    # Prepare all reactive fields.
    @renderer = new ReactiveField null
    @sceneManager = new ReactiveField null
    @cameraManager = new ReactiveField null
    @grid = new ReactiveField null

    @$meshCanvas = new ReactiveField null
    @canvas = new ReactiveField null
    @canvasPixelSize = new ReactiveField null
    @context = new ReactiveField null

  onCreated: ->
    super

    # Initialize components.
    @sceneManager new @constructor.SceneManager @

    @cameraManager new @constructor.CameraManager @

    if @options.grid
      @grid new @constructor.Grid @, @options.gridEnabled

    # Resize the canvas when browser window and zoom changes.
    @autorun =>
      canvas = @canvas()
      return unless canvas
      
      # Depend on window size.
      AM.Window.clientBounds()

      # Resize the back buffer to canvas element size, if it actually changed. If the pixel
      # canvas is not actually sized relative to window, we shouldn't force a redraw of the sprite.
      newSize =
        width: $(canvas).width()
        height: $(canvas).height()

      for key, value of newSize
        canvas[key] = value unless canvas[key] is value

      @canvasPixelSize newSize

  onRendered: ->
    super

    # DOM has been rendered, initialize.
    $meshCanvas = @$('.landsofillusions-assets-mesheditor-meshcanvas')
    @$meshCanvas $meshCanvas

    canvas = $meshCanvas.find('.canvas')[0]
    @canvas canvas
    @context canvas.getContext 'webgl'

    @renderer new @constructor.Renderer @

  onDestroyed: ->
    super

    @renderer().destroy()
    @sceneManager().destroy()
