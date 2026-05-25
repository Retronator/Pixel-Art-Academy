AM = Artificial.Mirage
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess
PlayerPositions = Chess.Interface.Play.PlayerPositions

class Chess.Interface.Play.PlayerCard extends AM.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Play.PlayerCard'
  @register @id()

  onCreated: ->
    super arguments...

    @play = @ancestorComponentOfType Chess.Interface.Play
    @chess = @play.chess

    @color = new ComputedField =>
      playerPosition = @data()
      flipped = @chess.interfaceManager()?.flippedBoard()

      # White is on the bottom if not flipped, black if interface is flipped.
      if (playerPosition is PlayerPositions.Bottom and not flipped) or (playerPosition is PlayerPositions.Top and flipped)
        Chess.Piece.Colors.White

      else
        Chess.Piece.Colors.Black

    @name = new ComputedField =>
      color = @color()
      playerType = @chess.gameManager()?.gameOptions()["#{color.toLowerCase()}PlayerType"]

      switch playerType
        when Chess.GameManager.PlayerTypes.Human then "Player"
        when Chess.GameManager.PlayerTypes.Computer then "Pixeltosh"

    @kingPiece = new ComputedField => new Chess.Piece @color(), Chess.Piece.Types.King

  positionClass: ->
    playerPosition = @data()
    _.kebabCase playerPosition
