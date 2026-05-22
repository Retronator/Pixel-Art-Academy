LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.PlayStart extends LOI.View
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.PlayStart'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @os = @interface.parent
    @chess = @os.getProgram Chess
    
  events: ->
    super(arguments...).concat
      'click .play-button': @onClickPlayButton
      
  onClickPlayButton: (event) ->
    @chess.interfaceManager().enterScreen Chess.InterfaceManager.Screens.Play
    @chess.gameManager().startNewGame
      whitePlayerType: Chess.GameManager.PlayerTypes.Computer
      blackPlayerType: Chess.GameManager.PlayerTypes.Computer
