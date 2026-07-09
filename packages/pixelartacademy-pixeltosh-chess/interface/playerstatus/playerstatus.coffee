AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.PlayerStatus extends AM.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.PlayerStatus'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @os = @ancestorComponentOfType PAA.Pixeltosh.OS
    @chess = @os.getProgram Chess
  
  ownedPiecesCount: -> Chess.ownedPiecesCount()

  events: ->
    super(arguments...).concat
      'click .buy-button': @onClickBuyButton

  onClickBuyButton: (event) ->
    @chess.interfaceManager().openShop()
