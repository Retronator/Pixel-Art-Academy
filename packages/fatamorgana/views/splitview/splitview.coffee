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

  onCreated: ->
    super arguments...

    @_dragging = new ReactiveField false
    
  dockSideClass: ->
    options = @data()
    _.toLower options.dockSide

  fixedClass: ->
    options = @data()
    'fixed' if options.fixed

  draggingClass: ->
    'dragging' if @_dragging()

  events: ->
    super(arguments...).concat
      'mousedown .divider': @onMouseDownDivider

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
      
    options = @data()

    # Remember starting dimensions of the main area.
    @_dimensionsStart =
      width: options.mainArea.width
      height: options.mainArea.height

    display = @callAncestorWith 'display'
    scale = display.scale()

    # Wire dragging handlers.
    @_dragging true

    $interface.on 'mousemove.fatamorgana-splitview', (event) =>
      dragDelta = 
        x: event.pageX - @_dragStart.x
        y: event.pageY - @_dragStart.y

      # Flip delta when moving from right or bottom.
      dragDelta.x *= -1 if options.dockSide is @constructor.DockSide.Right
      dragDelta.y *= -1 if options.dockSide is @constructor.DockSide.Bottom

      if options.dockSide in [@constructor.DockSide.Top, @constructor.DockSide.Bottom]
        # We're dragging from top or bottom, change main area height.
        options.mainArea.height = @_dimensionsStart.height + dragDelta.y / scale

      else
        # We're dragging from left or right, change main area width.
        options.mainArea.width = @_dimensionsStart.width + dragDelta.x / scale

      @interface.saveData()

    $interface.on 'mouseup.fatamorgana-splitview', (event) =>
      # Apply any size constraints.
      if options.dockSide in [@constructor.DockSide.Top, @constructor.DockSide.Bottom]
        if options.mainArea.heightStep
          options.mainArea.height = Math.round(options.mainArea.height / options.mainArea.heightStep) * options.mainArea.heightStep

        if options.mainArea.minHeight
          options.mainArea.height = Math.max options.mainArea.height, options.mainArea.minHeight

      else
        if options.mainArea.widthStep
          options.mainArea.width = Math.round(options.mainArea.width / options.mainArea.widthStep) * options.mainArea.widthStep

        if options.mainArea.minWidth
          options.mainArea.width = Math.max options.mainArea.width, options.mainArea.minWidth

      # End drag mode.
      $interface.off '.fatamorgana-splitview'

      @_dragging false
