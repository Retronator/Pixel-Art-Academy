LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.PlayerStatus extends LOI.View
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.PlayerStatus'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @os = @interface.parent
    @chess = @os.getProgram Chess
  
  ownedPiecesCount: -> Chess.ownedPiecesCount()

  events: ->
    super(arguments...).concat
      'click .buy-button': @onClickBuyButton

  onClickBuyButton: (event) ->
    @chess.interfaceManager().openShop()
