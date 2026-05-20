AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Assets
  class @Asset extends PAA.Practice.Project.Asset.Bitmap
    @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Macintosh
    
    @backgroundColor: -> new THREE.Color '#edddb5'
  
  class @TwoDimensional
    class @Asset extends Assets.Asset
      @fixedDimensions: -> width: 16, height: 16
    
    class @Pawn
      class @White extends TwoDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.TwoDimensional.Pawn.White'
        
        @displayName: -> "White pawn"
        
        @description: -> """
          Draw a white pawn piece.
          
          It is recommended to use dark lines, light coloring and shading, as well as an additional light outline around the whole piece to make it stand out on dark squares.
        """
        
        @initialize()
      
      class @Black extends TwoDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.TwoDimensional.Pawn.Black'
        
        @displayName: -> "Black pawn"
        
        @description: -> """
          Draw a black pawn piece.
          
          You can copy the white pawn using the option below and change the coloring and shading to make it black. Keep the light outline around the whole piece to make it stand out on dark squares.
        """
        
        @initialize()
    
    class @Knight
      class @White extends TwoDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.TwoDimensional.Knight.White'
        
        @displayName: -> "White knight"
        
        @description: -> """
          Draw a white knight piece.
          
          You can copy the base from the white pawn using the option below.
        """
    
        @initialize()
      
      class @Black extends TwoDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.TwoDimensional.Knight.Black'
        
        @displayName: -> "Black knight"
        
        @description: -> """
          Draw a black knight piece.
          
          You can copy the base from the white knight using the option below.
        """
    
        @initialize()
    
    class @Bishop
      class @White extends TwoDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.TwoDimensional.Bishop.White'
        
        @displayName: -> "White bishop"
        
        @description: -> """
          Draw a white bishop piece.
          
          You can copy the base from the white pawn using the option below.
        """
        
        @initialize()
      
      class @Black extends TwoDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.TwoDimensional.Bishop.Black'
        
        @displayName: -> "Black bishop"
        
        @description: -> """
          Draw a black bishop piece.
          
          You can copy the base from the white bishop using the option below.
        """
        
        @initialize()
    
    class @Rook
      class @White extends TwoDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.TwoDimensional.Rook.White'
        
        @displayName: -> "White rook"
        
        @description: -> """
          Draw a white rook piece.

          You can copy the base from the white pawn using the option below.
        """
        
        @initialize()
      
      class @Black extends TwoDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.TwoDimensional.Rook.Black'
        
        @displayName: -> "Black rook"
        
        @description: -> """
          Draw a black rook piece.
          
          You can copy the base from the white rook using the option below.
        """
        
        @initialize()
    
    class @Queen
      class @White extends TwoDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.TwoDimensional.Queen.White'
        
        @displayName: -> "White queen"
        
        @description: -> """
          Draw a white queen piece.

          You can copy the base from the white pawn using the option below.
        """
        
        @initialize()
      
      class @Black extends TwoDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.TwoDimensional.Queen.Black'
        
        @displayName: -> "Black queen"
        
        @description: -> """
          Draw a black queen piece. You can copy the base from the white queen using the option below.
        """
        
        @initialize()
    
    class @King
      class @White extends TwoDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.TwoDimensional.King.White'
        
        @displayName: -> "White king"
        
        @description: -> """
          Draw a white king piece.

          You can copy the base from the white pawn using the option below.
        """
        
        @initialize()
  
  class @ThreeDimensional
    class @Asset extends Assets.Asset
      @fixedDimensions: -> width: 16, height: 16
    
    class @Pawn
      class @White extends ThreeDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.ThreeDimensional.Pawn.White'
        
        @displayName: -> "White pawn"
        
        @description: -> """
          Draw a white pawn piece.
          
          It is recommended to use dark lines, light coloring and shading, as well as an additional light outline around the whole piece to make it stand out on dark squares.
        """
        
        @initialize()
      
      class @Black extends ThreeDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.ThreeDimensional.Pawn.Black'
        
        @displayName: -> "Black pawn"
        
        @description: -> """
          Draw a black pawn piece.
          
          You can copy the white pawn using the option below and change the coloring and shading to make it black. Keep the light outline around the whole piece to make it stand out on dark squares.
        """
        
        @initialize()
    
    class @Knight
      class @White extends ThreeDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.ThreeDimensional.Knight.White'
        
        @displayName: -> "White knight"
        
        @description: -> """
          Draw a white knight piece.
          
          You can copy the base from the white pawn using the option below.
        """
        
        @initialize()
      
      class @Black extends ThreeDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.ThreeDimensional.Knight.Black'
        
        @displayName: -> "Black knight"
        
        @description: -> """
          Draw a black knight piece.

          You can copy the base from the white knight using the option below.
        """
        
        @initialize()
    
    class @Bishop
      class @White extends ThreeDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.ThreeDimensional.Bishop.White'
        
        @displayName: -> "White bishop"
        
        @description: -> """
          Draw a white bishop piece.
          
          You can copy the base from the white pawn using the option below.
        """
        
        @initialize()
      
      class @Black extends ThreeDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.ThreeDimensional.Bishop.Black'
        
        @displayName: -> "Black bishop"
        
        @description: -> """
          Draw a black bishop piece.
          
          You can copy the base from the white bishop using the option below.
        """
        
        @initialize()
    
    class @Rook
      class @White extends ThreeDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.ThreeDimensional.Rook.White'
        
        @displayName: -> "White rook"
        
        @description: -> """
          Draw a white rook piece.
          
          You can copy the base from the white pawn using the option below.
        """
        
        @initialize()
      
      class @Black extends ThreeDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.ThreeDimensional.Rook.Black'
        
        @displayName: -> "Black rook"
        
        @description: -> """
          Draw a black rook piece.
          
          You can copy the base from the white rook using the option below.
        """
        
        @initialize()
    
    class @Queen
      class @White extends ThreeDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.ThreeDimensional.Queen.White'
        
        @displayName: -> "White queen"
        
        @description: -> """
          Draw a white queen piece.
          
          You can copy the base from the white pawn using the option below.
        """
        
        @initialize()
      
      class @Black extends ThreeDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.ThreeDimensional.Queen.Black'
        
        @displayName: -> "Black queen"
        
        @description: -> """
          Draw a black queen piece.
          
          You can copy the base from the white queen using the option below.
        """
        
        @initialize()
    
    class @King
      class @White extends ThreeDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.ThreeDimensional.King.White'
        
        @displayName: -> "White king"
        
        @description: -> """
          Draw a white king piece.
          
          You can copy the base from the white pawn using the option below.
        """
        
        @initialize()
      
      class @Black extends ThreeDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.ThreeDimensional.King.Black'
        
        @displayName: -> "Black king"
        
        @description: -> """
          Draw a black king piece.
          
          You can copy the base from the white king using the option below.
        """
        
        @initialize()
