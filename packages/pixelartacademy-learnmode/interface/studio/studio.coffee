AE = Artificial.Everywhere
AB = Artificial.Base
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
    @_focusPoint = _.clone @targetFocusPoint()
  
    @sceneSize =
      width: 480
      height: 400

  onRendered: ->
    super arguments...
  
    @app = @ancestorComponentOfType AB.App
    @app.addComponent @

    @$scene = @$('.scene')

    @_parallaxItems = for element in @$('.scene *[data-depth]')
      $element = $(element)

      $element: $element
      depth: $element.data('depth')
      origin:
        x: $element.data('originX')
        y: $element.data('originY')
  
    @_moveFocusEnabled = false
    @_moveFocusDuration = 0
    @_moveFocusTime = 0
    @_moveFocusCompleteCallback = null
    
    # Update scene style when viewport changes.
    @autorun (computation) =>
      @_updateSceneStyle()
    
  onDestroyed: ->
    super arguments...
  
    @app.removeComponent @

  setFocus: (targetFocusPoint) ->
    @_focusPoint = _.clone targetFocusPoint
    @targetFocusPoint targetFocusPoint
    return unless @isRendered()
  
    @_moveFocusEnabled = false
    @_updateSceneStyle()

  moveFocus: (targetFocusPointOrOptions) ->
    if targetFocusPointOrOptions.focusPoint
      targetFocusPoint = targetFocusPointOrOptions.focusPoint
      speedFactor = targetFocusPointOrOptions.speedFactor or 1
      
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

    duration = 0.03 / speedFactor * Math.sqrt(Math.pow(@_moveFocusDelta.x * @sceneSize.width, 2) + Math.pow(@_moveFocusDelta.y * @sceneSize.height, 2))
  
    @_moveFocusEnabled = true
    @_moveFocusDuration = duration
    @_moveFocusTime = 0
    
    new Promise (resolve, reject) =>
      @_moveFocusResolve = resolve

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

    focusFactorX = _.clamp (@_focusPoint.x * @sceneSize.width * scale - viewport.viewportBounds.width() / 2) / scrollableWidth, 0, 1
    focusFactorY = _.clamp (@_focusPoint.y * @sceneSize.height * scale - viewport.viewportBounds.height() / 2) / scrollableHeight, 0, 1
  
    focusFactorX = @_focusPoint.x if _.isNaN focusFactorX
    focusFactorY = @_focusPoint.y if _.isNaN focusFactorY

    left = -scrollableWidth * focusFactorX
    top = -scrollableHeight * focusFactorY
  
    @$scene.css "transform", "translate3d(#{left}px, #{top}px, 0)"

    for parallaxItem in @_parallaxItems
      left = (parallaxItem.origin.x - focusFactorX) * parallaxItem.depth * scrollableWidth * @horizontalParallaxFactor
      top = (parallaxItem.origin.y - focusFactorY) * parallaxItem.depth * scrollableHeight * @verticalParallaxFactor
  
      parallaxItem.$element.css "transform", "translate3d(#{left}px, #{top}px, 0)"

  artworkClasses: (artworkField) ->
    classes = [
      _.kebabCase artworkField
      'artwork'
    ]

    classes.join ' '
    
  draw: (appTime) ->
    return unless @_moveFocusEnabled
  
    @_moveFocusTime += appTime.elapsedAppTime
    progress = Math.min 1, @_moveFocusTime / @_moveFocusDuration
    progress = if progress < 0.5 then 2 * progress * progress else 1 - Math.pow(-2 * progress + 2, 2) / 2
    
    @_focusPoint.x = @_startingFocusPoint.x + @_moveFocusDelta.x * progress
    @_focusPoint.y = @_startingFocusPoint.y + @_moveFocusDelta.y * progress

    @_updateSceneStyle true
  
    if progress is 1
      @_moveFocusEnabled = false
      @_moveFocusResolve()
