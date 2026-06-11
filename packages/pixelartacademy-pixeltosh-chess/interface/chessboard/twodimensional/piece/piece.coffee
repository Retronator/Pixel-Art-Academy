AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Chessboard.TwoDimensional.Piece extends AM.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Chessboard.TwoDimensional.Piece'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @square = @ancestorComponentOfType(Chess.Interface.Chessboard.TwoDimensional.Square)?.square
    
    @chessboard = @ancestorComponentOfType Chess.Interface.Chessboard.TwoDimensional

    # Listen for chessboard animations if we're rendered in the chessboard.
    @chessboard?.pieceAnimation.addHandler @, @onAnimation
    @animating = new ReactiveField false
    @promoting = new ReactiveField false
    
    @bitmapId = new ComputedField =>
      piece = @data()
      type = if @promoting() then Chess.Piece.Types.Pawn else piece.type
      assetId = Chess.Assets.TwoDimensional[type][piece.color].id()
      
      return unless project = PAA.Practice.Project.documents.findOne Chess.projectId2D()
      return unless asset = _.find project.assets, (asset) => asset.id is assetId
      
      asset.bitmapId

    @bitmap = new ComputedField =>
      return unless bitmapId = @bitmapId()
      LOI.Assets.Bitmap.versionedDocuments.getDocumentForId bitmapId, false

  onDestroyed: ->
    super arguments...

    @chessboard?.pieceAnimation.removeHandlers @

  onRendered: ->
    super arguments...

    @$piece = @$('.pixelartacademy-pixeltosh-programs-chess-interface-chessboard-twodimensional-piece')
    
    if @_pendingPieceAnimation
      @_animatePieceAnimation @_pendingPieceAnimation 
      @_pendingPieceAnimation = null

  bitmapImageOptions: ->
    bitmap: => @bitmap()

  draggedClass: ->
    return unless pieceDraggingInfo = @chessboard?.pieceDraggingInfo()
    return unless pieceDraggingInfo.active

    'dragged' if pieceDraggingInfo.square is @square

  draggedStyle: ->
    return unless pieceDraggingInfo = @chessboard?.pieceDraggingInfo()
    return unless pieceDraggingInfo.active
    return unless pieceDraggingInfo.square is @square

    left: "#{pieceDraggingInfo.delta.x}rem"
    top: "#{pieceDraggingInfo.delta.y}rem"

  animatingClass: -> 'animating' if @animating()

  onAnimation: (animation) ->
    return unless animation.move.to is @square

    unless @$piece
      @_pendingPieceAnimation = animation
      return

    @_animatePieceAnimation animation

  _animatePieceAnimation: (animation) ->
    @promoting true if animation.promotion
    
    # Determine where we should animate from.
    if @chessboard.chess.interfaceManager()?.flippedBoard()
      fileOffset = animation.move.to.fileIndex - animation.move.from.fileIndex
      rankOffset = animation.move.from.rankIndex - animation.move.to.rankIndex

    else
      fileOffset = animation.move.from.fileIndex - animation.move.to.fileIndex
      rankOffset = animation.move.to.rankIndex - animation.move.from.rankIndex
      
    offset = 
      x: fileOffset * @chessboard.constructor.Square.Size
      y: rankOffset * @chessboard.constructor.Square.Size
    
    # Determine the style of the animation.
    slowCPUEmulation = LOI.settings.graphics.slowCPUEmulation.value()
    duration = if slowCPUEmulation then 400 else 300
    easing = if slowCPUEmulation then 'linear' else 'easeOutQuad'

    if slowCPUEmulation
      frameDuration = PAA.Pixeltosh.OS.Interface.slowCPUEmulationSmallFrameDelay * 1000
      lastFrameTime = null

    @$piece.velocity 'stop', true
    @animating true

    @$piece.velocity
      tween: [0, 1]
    ,
      duration: duration
      easing: easing
      progress: (elements, complete, remaining, start, tweenValue) =>
        if slowCPUEmulation
          currentFrameTime = Date.now()
          return if lastFrameTime? and currentFrameTime - lastFrameTime < frameDuration
          lastFrameTime = currentFrameTime
        
        @$piece.css
          left: "#{Math.round offset.x * tweenValue}rem"
          top: "#{Math.round offset.y * tweenValue}rem"
          
      complete: =>
        @$piece.css
          left: 0
          top: 0
        
        @promoting false
        @animating false
