AM = Artificial.Mirage
AMu = Artificial.Mummification
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

      @lightDirection = new ReactiveField new THREE.Vector3(0, -1, -1).normalize()
      @viewingAngle = @options.viewingAngle or new ReactiveField 0

      @_renderer = null
      @_landmarksSourceRenderer = null

      @renderer = new ComputedField =>
        return @options.renderer if @options.renderer
        
        return unless part = @data()
        return unless part.createRenderer
        @_renderer?.destroy()

        rendererOptions = _.clone @options.rendererOptions or {}

        if @designTerminal and _.startsWith part.options.type, 'Avatar.Outfit'
          rendererOptions.landmarksSource = =>
            # If we're editing a character, use its landmarks to position clothes.
            if characterRenderer = @designTerminal.screens.character.characterRenderer()
              characterRenderer.bodyRenderer

            else
              # Without a character, we rely on landmarks from default
              # body parts that get created when no data is loaded.
              unless @constructor._defaultBodyRenderer
                @constructor._defaultBodyPart = LOI.Character.Part.Types.Avatar.Body.create
                  dataLocation: new AMu.Hierarchy.Location
                    rootField: AMu.Hierarchy.create
                      templateClass: LOI.Character.Part.Template
                      type: LOI.Character.Part.Types.Avatar.Body.options.type
                      load: => null

                @constructor._defaultBodyRenderer = @constructor._defaultBodyPart.createRenderer
                  useArticleLandmarks: true

              @constructor._defaultBodyRenderer

          rendererOptions.centerOnUsedLandmarks = true
          rendererOptions.ignoreRenderingConditions = true

          rendererOptions.bodyPart = => @designTerminal.screens.character.character()?.avatar.body or @_defaultBodyPart

        @_renderer = part.createRenderer rendererOptions
        @_renderer

    onRendered: ->
      super arguments...

      @display = @callAncestorWith 'display'

      @$canvas = @$('canvas')
      @canvas = @$canvas[0]

      @$window = $(window)

      @context = @canvas.getContext '2d'

      @inViewport = new ReactiveField false
      @inViewport true unless @options.renderInViewportOnly

      if @options.renderInViewportOnly
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

        if @options.originOffset
          @context.translate @options.originOffset.x, @options.originOffset.y

        @context.save()
        
        # Draw and pass the root part in options so we can do different rendering paths based on it.
        renderer.drawToContext @context,
          rootPart: renderer.options.part
          lightDirection: @lightDirection()
          side: LOI.Engine.RenderingSides.getSideForAngle @viewingAngle()
          drawBody: @options.drawBody
          drawOutfit: @options.drawOutfit

        @context.restore()

    onDestroyed: ->
      super arguments...

      @_renderer?.destroy()
      @_defaultBodyRenderer?.destroy()

      if @options.renderInViewportOnly
        $(@options.scrollContainer).off 'scroll', @updateInViewport

      Meteor.clearInterval @_rotateInterval

    toggleRotation: ->
      if @_rotateInterval
        @stopRotation()

      else
        @startRotation()

    startRotation: ->
      return if @_rotateInterval

      @_rotateInterval = Meteor.setInterval =>
        @viewingAngle @viewingAngle() + Math.PI / 4
      ,
        250

    stopRotation: ->
      Meteor.clearInterval @_rotateInterval
      @_rotateInterval = null

    rotatableClass: ->
      'rotatable' if @options.rotatable

    events: ->
      super(arguments...).concat
        'mouseenter canvas': @onMouseEnterCanvas
        'mousemove canvas': @onMouseMoveCanvas
        'mouseleave canvas': @onMouseLeaveCanvas
        'mousedown canvas': @onMouseDownCanvas
        'dblclick canvas': @onMouseDoubleClickCanvas

    onMouseEnterCanvas: (event) ->
      @startRotation() if @options.rotateOnHover

    onMouseMoveCanvas: (event) ->
      return unless @$canvas

      canvasOffset = @$canvas.offset()

      percentageX = (event.pageX - canvasOffset.left) / @$canvas.outerWidth() * 2 - 1
      percentageY = (event.pageY - canvasOffset.top) / @$canvas.outerHeight() * 2 - 1

      @lightDirection new THREE.Vector3(-percentageX, percentageY, -1).normalize()

      if @_drag
        offset = event.pageX - @_dragStart
        @viewingAngle @_viewingAngleStart + offset * 0.04

    onMouseLeaveCanvas: (event) ->
      @lightDirection new THREE.Vector3(0, -1, -1).normalize()

      @stopRotation() if @options.rotateOnHover
      @viewingAngle 0 if @options.resetViewingAngleOnLeave

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

      @toggleRotation()
