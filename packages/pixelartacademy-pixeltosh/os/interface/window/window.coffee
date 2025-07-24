import {ComputedField} from "meteor/peerlibrary:computed-field"
import {ReactiveField} from "meteor/peerlibrary:reactive-field"

AB = Artificial.Base
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

scrollbarArrowSize = 10
scrollbarPositionSize = 12
scrollDelta = 10
scrollDelay = 0.125

class PAA.Pixeltosh.OS.Interface.Window extends FM.View
  # title: information for the window's title bar
  # scrollbar: information about the window's scrollbars
  #   horizontal: controls horizontal scrolling
  #     enabled: boolean whether scrolling should be possible
  #   vertical: controls vertical scrolling
  #     enabled: boolean whether scrolling should be possible
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
    
    # Have scroll left and top as normal fields so we can change them without going through program view's reactivity.
    @scrollTop = new ReactiveField 0
    @scrollLeft = new ReactiveField 0

    # Load initial values from progarm view.
    @autorun (computation) =>
      return unless programViewData = @programViewData()
      @scrollTop programViewData.value().scrollTop or 0
      @scrollLeft programViewData.value().scrollLeft or 0
      
    # Track size for calculating scrollbar dimensions.
    @contentAreaSize = new ReactiveField width: 0, height: 0
    @contentSize = new ReactiveField width: 0, height: 0
    
    @maxScroll = new ComputedField =>
      contentAreaSize = @contentAreaSize()
      contentSize = @contentSize()

      left: Math.max 0, contentSize.width - contentAreaSize.width
      top: Math.max 0,contentSize.height - contentAreaSize.height
    
    # Create fields for indicating changes.
    @windowMoveDelta = new ReactiveField null
    @windowResizeDelta = new ReactiveField null
    @scrollbarMoveDelta = new ReactiveField null

    # Allow folder to be informed when any of our settings changed so they can be saved.
    @changed = new AB.Event @
  
  onRendered: ->
    super arguments...
    
    # Observe content size.
    @$contentArea = @$('.content-area')
    updateContentAreaSize = =>
      scale = @os.display.scale()
      
      @contentAreaSize
        width: @$contentArea.outerWidth() / scale
        height: @$contentArea.outerHeight() / scale
    
    updateContentAreaSize()
    
    @_contentAreaResizeObserver = new ResizeObserver updateContentAreaSize
    @_contentAreaResizeObserver.observe @$contentArea[0]
    
    @$content = @$('.content')
    updateContentSize = =>
      scale = @os.display.scale()
      
      @contentSize
        width: @$content.outerWidth() / scale
        height: @$content.outerHeight() / scale
    
    updateContentSize()
    
    @_contentResizeObserver = new ResizeObserver updateContentSize
    @_contentResizeObserver.observe @$content[0]
    
  onDestroyed: ->
    super arguments...
    
    @_contentAreaResizeObserver?.disconnect()
    @_contentResizeObserver?.disconnect()
    
    Meteor.clearInterval @_scrollInterval
    @_endEvents()
    
  _endEvents: ->
    $(document).off '.pixelartacademy-pixeltosh-os-interface-window'
  
  programViewActive: ->
    programView = @ancestorComponentOfType PAA.Pixeltosh.Program.View
    programView.active()
    
  # Scrolling
  
  scrollInDirection: (vertical, sign) ->
    if vertical
      @_setScrollTop @_clampedScrollTop() + Math.sign(sign) * scrollDelta
      
    else
      @_setScrollLeft @_clampedScrollLeft() + Math.sign(sign) * scrollDelta
    
  scrollToElement: (element, options = {}) ->
    options.padding ?= 20
    options.animate ?= false
    
    # Get positions relative to document
    scale = @os.display.scale()

    $element = $(element)
    elementOffset = $element.offset()
    elementOffset.top /= scale
    elementOffset.left /= scale

    elementWidth = $element.outerWidth() / scale
    elementHeight = $element.outerHeight() / scale

    contentAreaOffset = @$contentArea.offset()
    contentAreaOffset.top /= scale
    contentAreaOffset.left /= scale

    contentAreaSize = @contentAreaSize()
    
    scrollTop = null
    scrollLeft = null
    
    if elementOffset.top < contentAreaOffset.top + options.padding
      scrollDownBy = contentAreaOffset.top + options.padding - elementOffset.top
      scrollTop = @_clampedScrollTop() - scrollDownBy
      
    else if elementOffset.top + elementHeight > contentAreaOffset.top + contentAreaSize.height - options.padding
      scrollUpBy = elementOffset.top + elementHeight - (contentAreaOffset.top + contentAreaSize.height - options.padding)
      scrollTop = @_clampedScrollTop() + scrollUpBy
      
    if elementOffset.left < contentAreaOffset.left + options.padding
      scrollRightBy = contentAreaOffset.left - elementOffset.left + options.padding
      scrollLeft = @_clampedScrollLeft() - scrollRightBy
      
    else if elementOffset.left + elementWidth > contentAreaOffset.left + contentAreaSize.width - options.padding
      scrollLeftBy = elementOffset.left + elementWidth - (contentAreaOffset.left + contentAreaSize.width - options.padding)
      scrollLeft = @_clampedScrollLeft() + scrollLeftBy
      
    unless options.animate
      @_setScrollTop scrollTop if scrollTop?
      @_setScrollLeft scrollLeft if scrollLeft?
      return
      
    new Promise (resolve, reject) =>
      scrollVerticalBy = -scrollDownBy if scrollDownBy
      scrollVerticalBy = scrollUpBy if scrollUpBy

      scrollHorizontalBy = -scrollRightBy if scrollRightBy
      scrollHorizontalBy = scrollLeftBy if scrollLeftBy
      
      scrollVerticalTimes = Math.abs scrollVerticalBy / scrollDelta if scrollVerticalBy
      scrollHorizontalTimes = Math.abs scrollHorizontalBy / scrollDelta if scrollHorizontalBy
      
      while scrollVerticalTimes > 0 or scrollHorizontalTimes > 0
        break if options.skipAnimation?()
        
        if scrollVerticalTimes > 0
          @scrollInDirection true, scrollVerticalBy
          scrollVerticalTimes--
          
          if scrollVerticalTimes <= 0
            @_setScrollTop scrollTop
          
        if scrollHorizontalTimes > 0
          @scrollInDirection false, scrollHorizontalBy
          scrollHorizontalTimes--
          
          if scrollHorizontalTimes <= 0
            @_setScrollLeft scrollLeft
          
        await _.waitForSeconds scrollDelay
        
      @_setScrollTop scrollTop if scrollTop?
      @_setScrollLeft scrollLeft if scrollLeft?

      resolve()
  
  _clampedScrollTop: ->
    _.clamp @scrollTop(), 0, @maxScroll().top
    
  _clampedScrollLeft: ->
    _.clamp @scrollLeft(), 0, @maxScroll().left
    
  _setScrollTop: (scrollTop) ->
    @scrollTop scrollTop
    @changed {scrollTop}
    
    # Perform a lazy set so that the interface doesn't rerender.
    @programViewData()?.lazySet 'scrollTop', @scrollTop()
    
  _setScrollLeft: (scrollLeft) ->
    @scrollLeft scrollLeft
    @changed {scrollLeft}
    
    # Perform a lazy set so that the interface doesn't rerender.
    @programViewData()?.lazySet 'scrollLeft', @scrollLeft()
    
  # Content and scrollbars
    
  contentStyle: ->
    left: "-#{@_clampedScrollLeft()}rem"
    top: "-#{@_clampedScrollTop()}rem"
    
  verticalScrollbarActive: ->
    @contentSize().height > @contentAreaSize().height
    
  horizontalScrollbarActive: ->
    @contentSize().width > @contentAreaSize().width
  
  verticalScrollbarActiveClass: ->
    'active' if @verticalScrollbarActive() and @programViewActive()
    
  horizontalScrollbarActiveClass: ->
    'active' if @horizontalScrollbarActive() and @programViewActive()
  
  verticalScrollbarDraggingClass: ->
    'dragging' if @scrollbarMoveDelta()?.top?
  
  horizontalScrollbarDraggingClass: ->
    'dragging' if @scrollbarMoveDelta()?.left?

  verticalScrollbarArrowDisabledAttribute: ->
    disabled: true unless @verticalScrollbarActive()
    
  horizontalScrollbarArrowDisabledAttribute: ->
    disabled: true unless @horizontalScrollbarActive()
    
  verticalScrollbarEnabled: ->
    @data().child('scrollbar').child('vertical').get('enabled') and @programViewActive()
  
  horizontalScrollbarEnabled: ->
    @data().child('scrollbar').child('horizontal').get('enabled') and @programViewActive()
  
  verticalScrollbarPositionStyle: ->
    @_verticalScrollbarPositionStyle @scrollTop()
  
  verticalScrollbarPositionMoveIndicatorStyle: ->
    @_verticalScrollbarPositionStyle @_clampedScrollTop() + @scrollbarMoveDelta()?.top or 0
    
  _verticalScrollbarPositionStyle: (scrollTop) ->
    {scrollAreaSpan, contentSpan} = @_verticalScrollbarDimensions()
    
    scrollRatio = _.clamp scrollTop / contentSpan, 0, 1
    
    top: "#{Math.round scrollAreaSpan * scrollRatio + scrollbarArrowSize + 1}rem"
    
  _verticalScrollbarDimensions: ->
    contentAreaSizeHeight = @contentAreaSize().height
    
    scrollAreaHeight = contentAreaSizeHeight - 2 * (scrollbarArrowSize + 1)
    scrollAreaSpan = scrollAreaHeight - scrollbarPositionSize
    
    contentSpan = @contentSize().height - contentAreaSizeHeight
    
    {scrollAreaSpan, contentSpan}
  
  horizontalScrollbarPositionStyle: ->
    @_horizontalScrollbarPositionStyle @scrollLeft()
  
  horizontalScrollbarPositionMoveIndicatorStyle: ->
    @_horizontalScrollbarPositionStyle @_clampedScrollLeft() + @scrollbarMoveDelta()?.left or 0
  
  _horizontalScrollbarPositionStyle: (scrollLeft) ->
    {scrollAreaSpan, contentSpan} = @_horizontalScrollbarDimensions()
    
    scrollRatio = _.clamp scrollLeft / contentSpan, 0, 1
    
    left: "#{Math.round scrollAreaSpan * scrollRatio + scrollbarArrowSize + 1}rem"
  
  _horizontalScrollbarDimensions: ->
    contentAreaSizeWidth = @contentAreaSize().width
    
    scrollAreaWidth = contentAreaSizeWidth - 2 * (scrollbarArrowSize + 1)
    scrollAreaSpan = scrollAreaWidth - scrollbarPositionSize
    
    contentSpan = @contentSize().width - contentAreaSizeWidth
    
    {scrollAreaSpan, contentSpan}

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
      'pointerdown .up.arrow': @onPointerDownUpArrow
      'pointerdown .down.arrow': @onPointerDownDownArrow
      'pointerdown .left.arrow': @onPointerDownLeftArrow
      'pointerdown .right.arrow': @onPointerDownRightArrow
      'pointerdown .vertical-scrollbar .position': @onPointerDownVerticalScrollbarPosition
      'pointerdown .horizontal-scrollbar .position': @onPointerDownHorizontalScrollbarPosition
      'wheel .content-area': @onWheelContentArea

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
    delay = if LOI.settings.graphics.slowCPUEmulation.value() then 75 else 0
    
    $document.on 'pointermove.pixelartacademy-pixeltosh-os-interface-window', _.throttle (event) =>
      return unless coordinates = cursor.coordinates()
      
      @windowMoveDelta
        x: Math.round coordinates.x - dragStartCoordinates.x
        y: Math.max minDeltaY, Math.round coordinates.y - dragStartCoordinates.y
    ,
      delay

    $document.on 'pointerup.pixelartacademy-pixeltosh-os-interface-window', (event) =>
      # End drag mode.
      @_endEvents()

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
    delay = if LOI.settings.graphics.slowCPUEmulation.value() then 75 else 0
    
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
  
  # Scrolling with arrows
  
  onPointerDownUpArrow: (event) ->
    @_startScrollingUntilPointerUp true, -1

  onPointerDownDownArrow: (event) ->
    @_startScrollingUntilPointerUp true, 1

  onPointerDownLeftArrow: (event) ->
    @_startScrollingUntilPointerUp false, -1
    
  onPointerDownRightArrow: (event) ->
    @_startScrollingUntilPointerUp false, 1
    
  _startScrollingUntilPointerUp: (vertical, sign) ->
    @scrollInDirection vertical, sign
    
    $document = $(document)
    
    Meteor.clearInterval @_scrollInterval
    
    @_scrollInterval = Meteor.setInterval =>
      @scrollInDirection vertical, sign
    ,
      scrollDelay * 1000
    
    $document.on 'pointerup.pixelartacademy-pixeltosh-os-interface-window', (event) =>
      $document.off '.pixelartacademy-pixeltosh-os-interface-window'
      
      Meteor.clearInterval @_scrollInterval

  # Scrolling by dragging the position indicator
  
  onPointerDownVerticalScrollbarPosition: (event) ->
    # Remember starting position of drag.
    cursor = @os.cursor()
    dragStartCoordinates = cursor.coordinates()

    # Wire dragging handlers.
    $document = $(document)
    
    $document.on 'pointermove.pixelartacademy-pixeltosh-os-interface-window',  (event) =>
      return unless coordinates = cursor.coordinates()
      
      scrollAreaDelta = coordinates.y - dragStartCoordinates.y
      {scrollAreaSpan, contentSpan} = @_verticalScrollbarDimensions()
      
      @scrollbarMoveDelta
        top: Math.round scrollAreaDelta / scrollAreaSpan * contentSpan

    $document.on 'pointerup.pixelartacademy-pixeltosh-os-interface-window', (event) =>
      # End drag mode.
      @_endEvents()

      delta = @scrollbarMoveDelta()
      @scrollbarMoveDelta null
    
      @_setScrollTop @_clampedScrollTop() + delta.top

  onPointerDownHorizontalScrollbarPosition: (event) ->
    # Remember starting position of drag.
    cursor = @os.cursor()
    dragStartCoordinates = cursor.coordinates()
    
    # Wire dragging handlers.
    $document = $(document)
    
    $document.on 'pointermove.pixelartacademy-pixeltosh-os-interface-window', (event) =>
      return unless coordinates = cursor.coordinates()
      
      scrollAreaDelta = coordinates.x - dragStartCoordinates.x
      {scrollAreaSpan, contentSpan} = @_horizontalScrollbarDimensions()
      
      @scrollbarMoveDelta
        left: Math.round scrollAreaDelta / scrollAreaSpan * contentSpan
    
    $document.on 'pointerup.pixelartacademy-pixeltosh-os-interface-window', (event) =>
      # End drag mode.
      @_endEvents()
      
      delta = @scrollbarMoveDelta()
      @scrollbarMoveDelta null
      
      @_setScrollLeft @_clampedScrollLeft() + delta.left
      
  # Scrolling with the mouse wheel
  
  onWheelContentArea: (event) ->
    # Accumulate wheel deltas.
    @_accumulatedWheelDelta ?= x: 0, y: 0

    @_accumulatedWheelDelta.x += event.originalEvent.deltaX
    @_accumulatedWheelDelta.y += event.originalEvent.deltaY
    
    if LOI.settings.graphics.slowCPUEmulation.value()
      # Throttle updates.
      @_throttledApply ?= _.throttle (event) =>
        @_applyWheelDelta()
      ,
        75
      
      @_throttledApply()
      
    else
      # Apply immediately.
      @_applyWheelDelta()

  _applyWheelDelta: ->
    scale = @os.display.scale()
  
    @_setScrollLeft Math.round @_clampedScrollLeft() + @_accumulatedWheelDelta.x / scale
    @_setScrollTop Math.round @_clampedScrollTop() + @_accumulatedWheelDelta.y / scale
    
    @_accumulatedWheelDelta.x = 0
    @_accumulatedWheelDelta.y = 0
