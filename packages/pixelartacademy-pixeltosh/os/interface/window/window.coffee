AB = Artificial.Base
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.OS.Interface.Window extends FM.View
  @id: -> 'PixelArtAcademy.Pixeltosh.OS.Interface.Window'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @os = @interface.parent
    
    @windowData = new ComputedField =>
      return unless programView = @ancestorComponentOfType PAA.Pixeltosh.Program.View
      programView.data()
      
    @windowSize = new ComputedField =>
      return unless windowData = @windowData()
      _.pick windowData.value(), ['width', 'height']
      
    @windowMoveDelta = new ReactiveField null
    
    @moved = new AB.Event @
    
  onDestroyed: ->
    super arguments...
    
    @_endWindowMove()
    
  moveIndicatorVisibleClass: ->
    'visible' if @windowMoveDelta()
    
  moveIndicatorAlternativeDitherClass: ->
    return unless delta = @windowMoveDelta()
    
    windowData = @windowData()
    left = windowData.get('left') + delta.x
    top = windowData.get('top') + delta.y
    
    'alternative-dither' if _.modulo(left, 2) is _.modulo(top, 2)
    
  moveIndicatorStyle: ->
    return unless delta = @windowMoveDelta()
    return unless windowSize = @windowSize()
    
    left: "#{delta.x - 1}rem"
    top: "#{delta.y - 1}rem"
    width: "#{@_roundToEven windowSize.width}rem"
    height: "#{@_roundToEven windowSize.height}rem"
  
  _roundToEven: (value) ->
    Math.round(value / 2) * 2
    
  events: ->
    super(arguments...).concat
      'pointerdown .title-bar': @onPointerDownTitleBar
      'click .title-bar .close-button': @onClickCloseButton
  
  onPointerDownTitleBar: (event) ->
    # Don't activate if clicking on the close button.
    return if event.target is @$('.title-bar .close-button')[0]
    
    @windowMoveDelta
      x: 0
      y: 0

    # Remember starting position of drag.
    @_dragStartX = event.pageX
    @_dragStartY = event.pageY

    display = @callAncestorWith 'display'
    scale = display.scale()
    
    # Calculate maximum Y offset (resulting top has to be 14 or more).
    windowData = @windowData()
    @_minDeltaY = PAA.Pixeltosh.OS.Interface.menuHeight - windowData.get 'top'

    # Wire dragging handlers.
    $document = $(document)
    $interface = @$('.pixelartacademy-pixeltosh-os-interface-window').closest('.fatamorgana-interface')
    
    # Create a throttled delta update function to emulate a slow CPU.
    delay = if LOI.settings.graphics.slowCPUEmulation.value() then 75 else 0
    
    $interface.on 'pointermove.pixelartacademy-pixeltosh-os-interface-window', _.throttle (event) =>
      @windowMoveDelta
        x: Math.round (event.pageX - @_dragStartX) / scale
        y: Math.max @_minDeltaY, Math.round (event.pageY - @_dragStartY) / scale
    ,
      delay

    $document.on 'pointerup.pixelartacademy-pixeltosh-os-interface-window', (event) =>
      # End drag mode.
      @_endWindowMove()

      delta = @windowMoveDelta()
      @windowMoveDelta null
    
      windowData = @windowData()
      
      newPosition =
        left: windowData.get('left') + delta.x
        top: windowData.get('top') + delta.y
      
      windowData.set 'left', newPosition.left
      windowData.set 'top', newPosition.top
      
      @moved newPosition
      
  _endWindowMove: ->
    $elements = [
      $(document)
      @$('.pixelartacademy-pixeltosh-os-interface-window')?.closest('.fatamorgana-interface')
    ]
    
    $element?.off '.pixelartacademy-pixeltosh-os-interface-window' for $element in $elements
  
  onClickCloseButton: (event) ->
    @interface.getOperator(PAA.Pixeltosh.OS.Interface.Actions.Close).execute()
