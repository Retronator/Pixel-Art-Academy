AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.Components.AvatarPartPreview extends AM.Component
  @register 'SanFrancisco.C3.Design.Terminal.Components.AvatarPartPreview'

  onRendered: ->
    super

    @lightDirection = new ReactiveField new THREE.Vector3(0, -1, -1).normalize()

    @renderOptions =
      lightDirection: @lightDirection

    @renderer = new ComputedField =>
      return unless part = @data()

      part.createRenderer @renderOptions

    @display = @callAncestorWith 'display'

    @$canvas = @$('canvas')
    @canvas = @$canvas[0]

    @context = @canvas.getContext '2d'

    @autorun =>
      unless renderer = @renderer()
        # There's no renderer so just clear whatever is drawn.
        @context.setTransform 1, 0, 0, 1, 0, 0
        @context.clearRect 0, 0, @canvas.width, @canvas.height
        return

      scale = @display.scale()

      @canvas.width = @$canvas.width() / scale
      @canvas.height = @$canvas.height() / scale

      @context.setTransform 1, 0, 0, 1, Math.floor(@canvas.width / 2), Math.floor(@canvas.height / 2)
      @context.clearRect 0, 0, @canvas.width, @canvas.height

      @context.save()
      renderer.drawToContext @context
      @context.restore()

  events: ->
    super.concat
      'mousemove canvas': @onMouseMoveCanvas
      'mouseleave canvas': @onMouseLeaveCanvas

  onMouseMoveCanvas: (event) ->
    canvasOffset = @$canvas.offset()

    percentageX = (event.pageX - canvasOffset.left) / @$canvas.outerWidth() * 2 - 1
    percentageY = (event.pageY - canvasOffset.top) / @$canvas.outerHeight() * 2 - 1

    @lightDirection new THREE.Vector3(-percentageX, percentageY, -1).normalize()

  onMouseLeaveCanvas: (event) ->
    @lightDirection new THREE.Vector3(0, -1, -1).normalize()
