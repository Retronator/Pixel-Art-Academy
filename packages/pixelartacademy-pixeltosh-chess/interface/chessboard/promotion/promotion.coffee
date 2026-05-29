AM = Artificial.Mirage
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Chessboard.Promotion extends AM.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Chessboard.Promotion'
  @register @id()
  
  onCreated: ->
    super arguments...

    @chessboard = @ancestorComponentOfType Chess.Interface.Chessboard
  
  pieces: ->
    promotionInfo = @data()

    for type in Chess.Piece.PromotionTypes
      new Chess.Piece promotionInfo.color, type

  events: ->
    super(arguments...).concat
      'click': @onClick
      'click .piece': @onClickPiece
      
  onClick: (event) ->
    return if $(event.target).closest('.promotion').length
    @chessboard.cancelPromotion()

  onClickPiece: (event) ->
    piece = @currentData()
    @chessboard.choosePromotion piece.type
