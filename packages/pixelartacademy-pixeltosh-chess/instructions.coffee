AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Instructions
  class @Instruction extends PAA.Pixeltosh.Instructions.Instruction
    @getChess: ->
      return unless os = PAA.PixelPad.Apps.Pixeltosh.getOS()
      program = os.activeProgram()
      return unless program instanceof Chess
      program
  
  class @UnavailableBoardDisplayType extends @Instruction
    @boardDisplayType: -> throw new AE.NotImplementedException "You have to specify which board display type this instruction checks."
    
    @activeConditions: ->
      return unless chess = @getChess()
      
      # Show when the board display choice is unavailable.
      return unless boardDisplayChoice= chess.interfaceManager()?.getBoardDisplayChoice()
      return if boardDisplayChoice.choiceIsAvailable()
      
      boardDisplayChoice.choice() is @boardDisplayType()
    
    bodyClass: -> PAA.Pixeltosh.Instructions.BodyClasses.Exclamation
    
    faceClass: -> PAA.Pixeltosh.Instructions.FaceClasses.Thoughtful
    
  class @Unavailable2DBoardDisplayType extends @UnavailableBoardDisplayType
    @id: -> "PixelArtAcademy.Pixeltosh.Programs.Chess.Instructions.Unavailable2DBoardDisplayType"
    @boardDisplayType: -> Chess.BoardDisplayTypes.TwoDimensional
    
    @message: -> """
      2D chessboard is locked. Complete the 'Pixel art fundamentals: size' goal to unlock it.
    """
    
    @initialize()
    
  class @Unavailable3DBoardDisplayType extends @UnavailableBoardDisplayType
    @id: -> "PixelArtAcademy.Pixeltosh.Programs.Chess.Instructions.Unavailable3DBoardDisplayType"
    @boardDisplayType: -> Chess.BoardDisplayTypes.ThreeDimensional
    
    @message: -> """
      3D chessboard is locked for now.
      
      You'll be able to unlock it in the future by completing the form element of art.
    """
    
    @initialize()
  
  class @PawnAssetMissing extends @Instruction
    @id: -> "PixelArtAcademy.Pixeltosh.Programs.Chess.Instructions.PawnAssetMissing"
    
    @activeConditions: ->
      return unless chess = @getChess()
      
      Chess.pawnAssetsMissing()

    @message: -> """
      Oh no! The game is missing the pawn sprites! You can draw them in the Drawing app.
    """

    @delayDuration: -> 2
  
    @initialize()
    
    faceClass: -> PAA.Pixeltosh.Instructions.FaceClasses.OhNo
    
    customClass: -> 'pixelartacademy-pixeltosh-programs-chess-instructions-wide'
