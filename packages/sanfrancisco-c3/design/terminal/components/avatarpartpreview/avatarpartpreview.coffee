AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.Components.AvatarPartPreview extends AM.Component
  @register 'SanFrancisco.C3.Design.Terminal.Components.AvatarPartPreview'

  constructor: (@options = {}) ->
    super arguments...

  class @Default extends AM.Component
    @register 'SanFrancisco.C3.Design.Terminal.Components.AvatarPartPreview.Default'

    constructor: (@options = {}) ->
      super arguments...

    onCreated: ->
      super arguments...

      @designTerminal = @ancestorComponentOfType C3.Design.Terminal

      @renderer = new ComputedField =>
        return unless part = @data()

        rendererOptions = _.clone @options.rendererOptions or {}

        if @designTerminal and _.startsWith part.options.type, 'Avatar.Outfit'
          rendererOptions.landmarksSource = => @designTerminal.screens.character.character().avatar.getRenderer().bodyRenderer
          rendererOptions.bodyPart = => @designTerminal.screens.character.character().avatar.body

        return unless part.createRenderer

        part.createRenderer rendererOptions

    onRendered: ->
      super arguments...

      @lightDirection = new ReactiveField new THREE.Vector3(0, -1, -1).normalize()
      @viewingAngle = @options.viewingAngle or new ReactiveField 0

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
        
        # Draw and pass the root part in options so we can do different rendering paths based on it.
        renderer.drawToContext @context,
          rootPart: renderer.options.part
          lightDirection: @lightDirection
          viewingAngle: @viewingAngle

        @context.restore()

    onDestroyed: ->
      super arguments...

      $(window).off 'scroll', @updateInViewport

    rotatableClass: ->
      'rotatable' if @options.rotatable

    events: ->
      super(arguments...).concat
        'mousemove canvas': @onMouseMoveCanvas
        'mouseleave canvas': @onMouseLeaveCanvas
        'mousedown canvas': @onMouseDownCanvas
        'dblclick canvas': @onMouseDoubleClickCanvas

    onMouseMoveCanvas: (event) ->
      return unless @$canvas

      canvasOffset = @$canvas.offset()

      percentageX = (event.pageX - canvasOffset.left) / @$canvas.outerWidth() * 2 - 1
      percentageY = (event.pageY - canvasOffset.top) / @$canvas.outerHeight() * 2 - 1

      @lightDirection new THREE.Vector3(-percentageX, percentageY, -1).normalize()

      if @_drag
        offset = event.pageX - @_dragStart
        @viewingAngle @_viewingAngleStart - offset * 0.04

    onMouseLeaveCanvas: (event) ->
      @lightDirection new THREE.Vector3(0, -1, -1).normalize()

    onMouseDownCanvas: (event) ->
      event.preventDefault()

      return unless @options.rotatable

      Meteor.clearInterval @_rotateInterval
      @_rotateInterval = null

      @_dragStart = event.pageX
      @_viewingAngleStart = @viewingAngle()
      @_drag = true
      
      $(document).on 'mouseup.sanfrancisco-c3-design-terminal-components-avatarpartpreview-default', =>
        $(document).off '.sanfrancisco-c3-design-terminal-components-avatarpartpreview-default'
        @_drag = false

    onMouseDoubleClickCanvas: (event) ->
      return unless @options.rotatable

      if @_rotateInterval
        Meteor.clearInterval @_rotateInterval
        @_rotateInterval = null

      else
        @_rotateInterval = Meteor.setInterval =>
          @viewingAngle @viewingAngle() + Math.PI / 4
        ,
          250
