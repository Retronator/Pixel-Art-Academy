PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Chessboard.TwoDimensional extends Chess.Interface.Chessboard.TwoDimensional
  @register @id()

  onCreated: ->
    super arguments...

    @pieceDraggingInfo = new ReactiveField null

  onDestroyed: ->
    super arguments...

    @_endDraggingEvents()

  _endDraggingEvents: ->
    $(document).off '.pixelartacademy-pixeltosh-programs-chess-interface-chessboard-twodimensional-dragging'

  onPointerDownSquare: (square, event) ->
    return unless @humanCanMovePieceOnSquare square

    previousSelectedSquare = @selectedSquare()
    @selectedSquare square

    @_endDraggingEvents()

    cursor = @os.cursor()
    dragStartCoordinates = cursor.coordinates()
    return unless dragStartCoordinates

    $destinationSquare = $(event.currentTarget)
    squareOffset = $destinationSquare.offset()
    displayScale = @os.display.scale()

    squareCenterCoordinates =
      x: dragStartCoordinates.x + ($destinationSquare.outerWidth() / 2 + squareOffset.left - event.pageX) / displayScale
      y: dragStartCoordinates.y + ($destinationSquare.outerHeight() / 2 + squareOffset.top - event.pageY) / displayScale

    # Prepare dragging info, but don't activate dragging yet since we'll wait for actual cursor movement.
    pieceDraggingInfo =
      square: square
      delta:
        x: 0
        y: 0
      active: false

    @pieceDraggingInfo pieceDraggingInfo

    $document = $(document)
    cursor = @os.cursor()

    $document.on 'pointermove.pixelartacademy-pixeltosh-programs-chess-interface-chessboard-twodimensional-dragging', (event) =>
      return unless coordinates = cursor.coordinates()
      return if coordinates.x is dragStartCoordinates.x and coordinates.y is dragStartCoordinates.y

      # Activate dragging only once the rounded cursor coordinates change while still down.
      pieceDraggingInfo.active = true
      pieceDraggingInfo.delta =
        x: coordinates.x - squareCenterCoordinates.x
        y: coordinates.y - squareCenterCoordinates.y

      @selectedSquare square
      @pieceDraggingInfo _.extend {}, pieceDraggingInfo
      cursor.requestClass 'grabbing', @

    $document.on 'pointerup.pixelartacademy-pixeltosh-programs-chess-interface-chessboard-twodimensional-dragging', (event) =>
      @_endDraggingEvents()

      wasDragging = @pieceDraggingInfo()?.active
      @pieceDraggingInfo null
      cursor.endClassRequests @

      if wasDragging or previousSelectedSquare isnt square
        @_ignoreNextClick = true
        Meteor.setTimeout => @_ignoreNextClick = false

      return unless wasDragging

      $destinationSquare = $(event.target).closest '.pixelartacademy-pixeltosh-programs-chess-interface-chessboard-twodimensional-square'
      destinationSquare = Chess.Square[$destinationSquare.data 'square-name']

      if destinationSquare in @provider().getLegalDestinationsFromSquare square
        @performMoveTo destinationSquare, true

      @selectedSquare null
