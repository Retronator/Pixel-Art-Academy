AB = Artificial.Base
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.OS.Interface.Window extends FM.View
  # title: information for the window's title bar
  # scrollbars: information about the window's scrollbars for ScrollableArea
  @id: -> 'PixelArtAcademy.Pixeltosh.OS.Interface.Window'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @os = @interface.parent
    
    # Properties coming from the program view.
    
    @programViewData = new ComputedField =>
      return unless programView = @ancestorComponentOfType PAA.Pixeltosh.Program.View
      programView.data()
      
    @windowSize = new ComputedField =>
      return unless programViewData = @programViewData()
      _.pick programViewData.value(), ['width', 'height']
    
    # Create fields for indicating changes.
    @windowMoveDelta = new ReactiveField null
    @windowResizeDelta = new ReactiveField null

    # Allow folder to be informed when any of our settings changed so they can be saved.
    @changed = new AB.Event @
  
  onDestroyed: ->
    super arguments...
    
    @_endEvents()
    
  _endEvents: ->
    $(document).off '.pixelartacademy-pixeltosh-os-interface-window'
  
  scrollToElement: (element, options) ->
    scrollableArea = @childComponentsOfType(PAA.Pixeltosh.OS.Interface.ScrollableArea)[0]
    scrollableArea.scrollToElement element, options
    
  programViewActive: ->
    programView = @ancestorComponentOfType PAA.Pixeltosh.Program.View
    programView.active()

  # Move indicator
    
  moveIndicatorVisibleClass: ->
    'visible' if @windowMoveDelta() or @windowResizeDelta()
  
  moveIndicatorDitherClasses: ->
    resizeDelta = @windowResizeDelta()
    moveDelta = @windowMoveDelta()
    
    programViewData = @programViewData()
    left = programViewData.get('left') + (moveDelta?.x or 0)
    top = programViewData.get('top') + (moveDelta?.y or 0)
    width = @_roundToEven programViewData.get('width') + (resizeDelta?.width or 0)
    height = @_roundToEven programViewData.get('height') + (resizeDelta?.height or 0)
    
    widthClass = if Math.floor(width / 2) % 2 then 'dither-width-odd' else 'dither-width-even'
    heightClass = if Math.floor(height / 2) % 2 then 'dither-height-odd' else 'dither-height-even'
    inverseClass = if _.modulo(left, 2) is _.modulo(top, 2) then 'dither-inverse' else ''
    
    "#{widthClass} #{heightClass} #{inverseClass}"
    
  moveIndicatorStyle: ->
    return unless windowSize = @windowSize()
    moveDelta = @windowMoveDelta()
    resizeDelta = @windowResizeDelta()
    
    left: "#{(moveDelta?.x or 0) - 1}rem"
    top: "#{(moveDelta?.y or 0) - 1}rem"
    width: "#{@_roundToEven windowSize.width + (resizeDelta?.width or 0)}rem"
    height: "#{@_roundToEven windowSize.height + (resizeDelta?.height or 0)}rem"
  
  _roundToEven: (value) ->
    Math.round(value / 2) * 2
    
  events: ->
    super(arguments...).concat
      'pointerdown .title-bar': @onPointerDownTitleBar
      'pointerdown .resize-control': @onPointerDownResizeControl
      'click .title-bar .close-button': @onClickCloseButton

  # Moving the window
  
  onPointerDownTitleBar: (event) ->
    # Don't activate if clicking on the close button.
    return if event.target is @$('.title-bar .close-button')[0]
    
    @windowMoveDelta
      x: 0
      y: 0

    # Remember starting position of drag.
    cursor = @os.cursor()
    dragStartCoordinates = cursor.coordinates()
    
    # Calculate maximum Y offset (resulting top has to be 14 or more).
    programViewData = @programViewData()
    minDeltaY = PAA.Pixeltosh.OS.Interface.menuHeight - programViewData.get 'top'

    # Wire dragging handlers.
    $document = $(document)
    
    # Create a throttled delta update function to emulate a slow CPU.
    delay = 0
    delay = PAA.Pixeltosh.OS.Interface.slowCPUEmulationLargeFrameDelay * 1000 if LOI.settings.graphics.slowCPUEmulation.value()
    
    $document.on 'pointermove.pixelartacademy-pixeltosh-os-interface-window', throttledMove = _.throttle (event) =>
      return unless coordinates = cursor.coordinates()
      
      @windowMoveDelta
        x: Math.round coordinates.x - dragStartCoordinates.x
        y: Math.max minDeltaY, Math.round coordinates.y - dragStartCoordinates.y
    ,
      delay

    $document.on 'pointerup.pixelartacademy-pixeltosh-os-interface-window', (event) =>
      # End drag mode.
      @_endEvents()
      throttledMove.cancel()

      delta = @windowMoveDelta()
      @windowMoveDelta null
    
      programViewData = @programViewData()
      
      newProperties =
        left: programViewData.get('left') + delta.x
        top: programViewData.get('top') + delta.y
      
      programViewData.set 'left', newProperties.left
      programViewData.set 'top', newProperties.top
      
      @changed newProperties
  
  # Resizing the window
  
  onPointerDownResizeControl: (event) ->
    @windowResizeDelta
      width: 0
      height: 0

    # Remember starting position of drag.
    cursor = @os.cursor()
    dragStartCoordinates = cursor.coordinates()
    
    # Calculate maximum Y offset (resulting top has to be 14 or more).
    programViewData = @programViewData()
    minDeltaWidth = 60 - programViewData.get 'width'
    minDeltaHeight = 75 - programViewData.get 'height'

    # Wire dragging handlers.
    $document = $(document)
    
    # Create a throttled delta update function to emulate a slow CPU.
    delay = 0
    delay = PAA.Pixeltosh.OS.Interface.slowCPUEmulationLargeFrameDelay * 1000 if LOI.settings.graphics.slowCPUEmulation.value()
    
    $document.on 'pointermove.pixelartacademy-pixeltosh-os-interface-window', _.throttle (event) =>
      return unless coordinates = cursor.coordinates()
      
      @windowResizeDelta
        width: Math.max minDeltaWidth, Math.round coordinates.x - dragStartCoordinates.x
        height: Math.max minDeltaHeight, Math.round coordinates.y - dragStartCoordinates.y
    ,
      delay

    $document.on 'pointerup.pixelartacademy-pixeltosh-os-interface-window', (event) =>
      # End drag mode.
      @_endEvents()

      delta = @windowResizeDelta()
      @windowResizeDelta null
    
      programViewData = @programViewData()
      
      newProperties =
        width: programViewData.get('width') + delta.width
        height: programViewData.get('height') + delta.height
      
      programViewData.set 'width', newProperties.width
      programViewData.set 'height', newProperties.height
      
      @changed newProperties
  
  # Closing the window
  
  onClickCloseButton: (event) ->
    @interface.getOperator(PAA.Pixeltosh.OS.Interface.Actions.Close).execute()
  
  # Forwarding scrollable area changes

  onScrollableAreaChanged: (changes) ->
    @changed changes
