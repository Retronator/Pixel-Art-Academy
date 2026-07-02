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
      
      Chess.pawnAssetMissing()

    @message: -> """
      Oh no! The game is missing the pawn sprite! You can draw it in the Drawing app.
    """

    @delayDuration: -> 2
  
    @initialize()
    
    faceClass: -> PAA.Pixeltosh.Instructions.FaceClasses.OhNo
    
    customClass: -> 'pixelartacademy-pixeltosh-programs-chess-instructions-wide'

  class @RepeatLessons extends @Instruction
    @id: -> "PixelArtAcademy.Pixeltosh.Programs.Chess.Instructions.RepeatLessons"
    
    @message: -> """
      You can repeat each lesson once to gain more currency.
    """

    @activeConditions: ->
      return unless chess = @getChess()
      return unless interfaceManager = chess.interfaceManager()
      return unless interfaceManager.inMenu() and interfaceManager.shopIsOpen()
      
      return unless lessonManager = chess.lessonManager()
      categories = lessonManager.availableCategories()

      # See if we have any available lessons that haven't been completed yet.
      for category in categories
        for lesson in category.lessons
          return if lesson.available() and not lesson.completedCount()
          
      # See if we can afford to buy another piece.
      currency = Chess.currency()

      for pieceType of Chess.Piece.Types
        ownedCount = Chess.ownedPiecesCount pieceType
        pieceInfo = Chess.Piece.InfoForType[pieceType]
        requiredCount = pieceInfo.requiredCount
        
        continue if ownedCount is requiredCount

        # This is the cheapest needed piece. Show instruction if we can't cover its value.
        return currency < pieceInfo.value
    
    @initialize()
    
    bodyClass: -> PAA.Pixeltosh.Instructions.BodyClasses.Exclamation
    
    faceClass: -> PAA.Pixeltosh.Instructions.FaceClasses.Thoughtful
    
    customClass: -> 'pixelartacademy-pixeltosh-programs-chess-instructions-narrow'

  class @ChangeTheme extends @Instruction
    @id: -> "PixelArtAcademy.Pixeltosh.Programs.Chess.Instructions.ChangeTheme"
    
    @message: -> """
      You can change the look of the board in the Theme menu.
    """
    
    @activeConditions: ->
      # Don't show if you've changed any of the themes.
      if project = Chess.currentProject()
        return if project.interfaceTheme or project.chessboardTheme
      
      # Show in the menu when you've completed 3 pawn lessons.
      return unless chess = @getChess()
      return unless interfaceManager = chess.interfaceManager()
      return unless interfaceManager.inMenu()
      
      Chess.Lessons.Categories.Pawn.completedLessonsCount() is 3
    
    @delayDuration: -> 2
    
    @initialize()
    
    bodyClass: -> PAA.Pixeltosh.Instructions.BodyClasses.Exclamation
    
    faceClass: -> PAA.Pixeltosh.Instructions.FaceClasses.Thoughtful
