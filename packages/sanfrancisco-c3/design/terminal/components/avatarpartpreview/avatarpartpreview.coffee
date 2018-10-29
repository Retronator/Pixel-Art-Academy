AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.Components.AvatarPartPreview extends AM.Component
  @register 'SanFrancisco.C3.Design.Terminal.Components.AvatarPartPreview'

  class @Default extends AM.Component
    @register 'SanFrancisco.C3.Design.Terminal.Components.AvatarPartPreview.Default'

    onRendered: ->
      super arguments...

      @lightDirection = new ReactiveField new THREE.Vector3(0, -1, -1).normalize()

      @display = @callAncestorWith 'display'

      @$canvas = @$('canvas')
      @canvas = @$canvas[0]

      @$window = $(window)

      @context = @canvas.getContext '2d'

      @inViewport = new ReactiveField false

      @updateInViewport = =>
        viewport = @display.viewport()

        canvasDimensions = @$canvas.offset()
        canvasDimensions.top -= @$window.scrollTop()
        canvasDimensions.bottom = canvasDimensions.top + @$canvas.height()

        # See if the canvas is anywhere in the viewport + one viewport height before/after.
        viewportHeight = viewport.viewportBounds.height()

        @inViewport canvasDimensions.top < viewport.viewportBounds.bottom() + viewportHeight and canvasDimensions.bottom > viewport.viewportBounds.top() - viewportHeight

      @autorun (computation) =>
        @updateInViewport()

      $(window).on 'scroll', @updateInViewport

      @autorun (computation) =>
        return unless @inViewport()

        part = @data()
        
        unless renderer = part?.renderer()
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
        
        # Draw and pass the root part in options so we can do different rendering paths based on it.
        renderer.drawToContext @context,
          rootPart: renderer.options.part
          lightDirection: @lightDirection

        @context.restore()

    onDestroyed: ->
      super arguments...

      $(window).off 'scroll', @updateInViewport

    events: ->
      super(arguments...).concat
        'mousemove canvas': @onMouseMoveCanvas
        'mouseleave canvas': @onMouseLeaveCanvas

    onMouseMoveCanvas: (event) ->
      canvasOffset = @$canvas.offset()

      percentageX = (event.pageX - canvasOffset.left) / @$canvas.outerWidth() * 2 - 1
      percentageY = (event.pageY - canvasOffset.top) / @$canvas.outerHeight() * 2 - 1

      @lightDirection new THREE.Vector3(-percentageX, percentageY, -1).normalize()

    onMouseLeaveCanvas: (event) ->
      @lightDirection new THREE.Vector3(0, -1, -1).normalize()
