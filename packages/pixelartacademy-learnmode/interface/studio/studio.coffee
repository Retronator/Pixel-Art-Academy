AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
LM = PixelArtAcademy.LearnMode

class LM.Interface.Studio extends AM.Component
  @id: -> 'PixelArtAcademy.LearnMode.Interface.Studio'
  @register @id()
  template: -> @constructor.id()

  @version: -> '0.0.1'
  
  @FocusPoints:
    Play:
      x: 0.5
      y: 0
    MainMenu:
      x: 0.5
      y: 1
      
  constructor: ->
    super arguments...
  
    @horizontalParallaxFactor = 0
    @verticalParallaxFactor = 0.25
  
    @targetFocusPoint = new ReactiveField @constructor.FocusPoints.MainMenu
    @_focusPoint = @targetFocusPoint()
  
    @sceneSize =
      width: 480
      height: 400

  onRendered: ->
    super arguments...

    @$scene = @$('.scene')

    @_parallaxItems = for element in @$('.scene *[data-depth]')
      $element = $(element)

      $element: $element
      depth: $element.data('depth')
      origin:
        x: $element.data('originX')
        y: $element.data('originY')

    # Dummy DOM element to run velocity on.
    @$animate = $('<div>')

    # Update scene style when viewport changes.
    @autorun (computation) =>
      @_updateSceneStyle()

  setFocus: (targetFocusPoint) ->
    @_focusPoint = targetFocusPoint
    @targetFocusPoint targetFocusPoint
    return unless @isRendered()

    @$animate.velocity('stop', 'moveFocus')
    @_updateSceneStyle()

  moveFocus: (targetFocusPointOrOptions) ->
    if targetFocusPointOrOptions.focusPoint
      targetFocusPoint = targetFocusPointOrOptions.focusPoint
      speedFactor = targetFocusPointOrOptions.speedFactor or 1
      completeCallback = targetFocusPointOrOptions.completeCallback
      
    else
      targetFocusPoint = targetFocusPointOrOptions
      speedFactor = 1
      
    # We clamp the focus point so that it won't get clamped later.
    @_startingFocusPoint = @_clampFocusPoint @_focusPoint
    @targetFocusPoint targetFocusPoint
    targetFocusPoint = @_clampFocusPoint targetFocusPoint

    @_moveFocusDelta =
      x: targetFocusPoint.x - @_startingFocusPoint.x
      y: targetFocusPoint.y - @_startingFocusPoint.y

    duration = 30 / speedFactor * Math.sqrt(Math.pow(@_moveFocusDelta.x * @sceneSize.width, 2) + Math.pow(@_moveFocusDelta.y * @sceneSize.height, 2))

    @$animate.velocity('stop', 'moveFocus').velocity
      tween: [1, 0]
    ,
      duration: duration
      easing: 'ease-in-out'
      queue: 'moveFocus'
      progress: (elements, complete, remaining, current, tweenValue) =>
        @_focusPoint =
          x: @_startingFocusPoint.x + @_moveFocusDelta.x * tweenValue
          y: @_startingFocusPoint.y + @_moveFocusDelta.y * tweenValue

        @_updateSceneStyle true
      complete: completeCallback

    @$animate.dequeue('moveFocus')

  _clampFocusPoint: (focusPoint) ->
    viewport = LOI.adventure.interface.display.viewport()
    scale = LOI.adventure.interface.display.scale()

    halfWidth = viewport.viewportBounds.width() / scale / 2
    halfHeight = viewport.viewportBounds.height() / scale / 2

    x: _.clamp focusPoint.x, halfWidth / @sceneSize.width, (@sceneSize.width - halfWidth) / @sceneSize.width
    y: _.clamp focusPoint.y, halfHeight / @sceneSize.height, (@sceneSize.height - halfHeight) / @sceneSize.height

  _updateSceneStyle: (parallaxOnly) ->
    viewport = LOI.adventure.interface.display.viewport()
    scale = LOI.adventure.interface.display.scale()
  
    @$('.pixelartacademy-learnmode-interface-studio').css viewport.viewportBounds.toDimensions() unless parallaxOnly

    scrollableWidth = @sceneSize.width * scale - viewport.viewportBounds.width()
    scrollableHeight = @sceneSize.height * scale - viewport.viewportBounds.height()

    focusFactor =
      x: _.clamp (@_focusPoint.x * @sceneSize.width * scale - viewport.viewportBounds.width() / 2) / scrollableWidth, 0, 1
      y: _.clamp (@_focusPoint.y * @sceneSize.height * scale - viewport.viewportBounds.height() / 2) / scrollableHeight, 0, 1

    focusFactor.x = @_focusPoint.x if _.isNaN focusFactor.x
    focusFactor.y = @_focusPoint.y if _.isNaN focusFactor.y

    left = -scrollableWidth * focusFactor.x
    top = -scrollableHeight * focusFactor.y

    @$scene.css transform: "translate3d(#{left}px, #{top}px, 0)"

    for parallaxItem in @_parallaxItems
      left = (parallaxItem.origin.x - focusFactor.x) * parallaxItem.depth * scrollableWidth * @horizontalParallaxFactor
      top = (parallaxItem.origin.y - focusFactor.y) * parallaxItem.depth * scrollableHeight * @verticalParallaxFactor

      parallaxItem.$element.css transform: "translate3d(#{left}px, #{top}px, 0)"

  artworkClasses: (artworkField) ->
    classes = [
      _.kebabCase artworkField
      'artwork'
    ]

    classes.join ' '
