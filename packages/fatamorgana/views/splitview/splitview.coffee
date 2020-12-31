AM = Artificial.Mirage
FM = FataMorgana

class FM.SplitView extends FM.View
  # fixed: boolean telling if the split is fixed
  # mainArea: the component that controls the size of the split
  # remainingArea: the component that fills the rest of the view
  # dockSide: the side to which the main area is positioned
  @id: -> 'FataMorgana.SplitView'
  @register @id()

  @DockSide:
    Top: 'Top'
    Bottom: 'Bottom'
    Left: 'Left'
    Right: 'Right'
    
  @dataFields: -> [
    'fixed'
    'dockSide'
  ]

  onCreated: ->
    super arguments...

    @_dragging = new ReactiveField false
    
  dockSideClass: ->
    _.toLower @dockSide()

  fixedClass: ->
    'fixed' if @fixed()

  draggingClass: ->
    'dragging' if @_dragging()
    
  showDivider: ->
    # Don't show the divider when the main area controls its own size.
    return true unless mainArea = @childComponents()[0]
    not mainArea.childComponentOverridesSize()

  events: ->
    super(arguments...).concat
      'mousedown .fatamorgana-splitview > .divider': @onMouseDownDivider

  onMouseDownDivider: (event) ->
    # Only react to the divider directly in this component.
    return unless $(event.target).closest('.fatamorgana-splitview')[0] is @$('.fatamorgana-splitview')[0]

    # Prevent browser select/dragging behavior.
    event.preventDefault()

    $interface = @interface.$('.fatamorgana-interface')

    # Remember starting position of drag.
    @_dragStart =
      x: event.pageX
      y: event.pageY
      
    mainAreaData = @data().child 'mainArea'
    dockSide = @dockSide()

    # Remember starting dimensions of the main area.
    @_dimensionsStart =
      width: mainAreaData.get 'width'
      height: mainAreaData.get 'height'

    display = @callAncestorWith 'display'
    scale = display.scale()

    # Wire dragging handlers.
    @_dragging true

    $interface.on 'mousemove.fatamorgana-splitview', (event) =>
      dragDelta =
        x: event.pageX - @_dragStart.x
        y: event.pageY - @_dragStart.y

      # Flip delta when moving from right or bottom.
      dragDelta.x *= -1 if dockSide is @constructor.DockSide.Right
      dragDelta.y *= -1 if dockSide is @constructor.DockSide.Bottom

      if dockSide in [@constructor.DockSide.Top, @constructor.DockSide.Bottom]
        # We're dragging from top or bottom, change main area height.
        mainAreaData.set 'height', @_dimensionsStart.height + dragDelta.y / scale

      else
        # We're dragging from left or right, change main area width.
        mainAreaData.set 'width', @_dimensionsStart.width + dragDelta.x / scale

    $interface.on 'mouseup.fatamorgana-splitview', (event) =>
      mainArea = mainAreaData.value()

      # Apply any size constraints.
      if dockSide in [@constructor.DockSide.Top, @constructor.DockSide.Bottom]
        if mainArea.heightStep
          mainArea.height = Math.round(mainArea.height / mainArea.heightStep) * mainArea.heightStep

        if mainArea.minHeight
          mainArea.height = Math.max mainArea.height, mainArea.minHeight

        mainAreaData.set 'height', mainArea.height

      else
        if mainArea.widthStep
          mainArea.width = Math.round(mainArea.width / mainArea.widthStep) * mainArea.widthStep

        if mainArea.minWidth
          mainArea.width = Math.max mainArea.width, mainArea.minWidth

        mainAreaData.set 'width', mainArea.width

      # End drag mode.
      $interface.off '.fatamorgana-splitview'

      @_dragging false
