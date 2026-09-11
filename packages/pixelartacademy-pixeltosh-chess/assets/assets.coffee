AE = Artificial.Everywhere
AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

class Chess.Assets
  class @Asset extends PAA.Practice.Asset.Bitmap
    @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Macintosh
    
    @backgroundColor: -> new THREE.Color '#edddb5'
    
    @briefComponentClass: -> Chess.Assets.BriefComponent

    @availablePublications: -> [
      'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Publications.SixtyFourSquares.ArtOfTheBoard'
    ]

    @copySourceAssets: -> [] # Override if you can copy this asset's art from another asset.
    
    @projectClass: -> throw new AE.NotImplementedException "Asset must specify which project class it belongs to."

    @addToProject: (projectId) ->
      assetId = @id()
      
      # Load the Macintosh palette.
      macintoshPalette = await new Promise (resolve) =>
        Tracker.autorun (computation) =>
          LOI.Assets.Palette.forName.subscribeContent LOI.Assets.Palette.SystemPaletteNames.Macintosh
          return unless palette = LOI.Assets.Palette.documents.findOne name: LOI.Assets.Palette.SystemPaletteNames.Macintosh
          computation.stop()
          resolve palette
  
      # Create the bitmap.
      creationTime = new Date
      
      dimensions = @fixedDimensions()
      width = dimensions.width
      height = dimensions.height
      
      bitmapData =
        versioned: true
        profileId: LOI.adventure.profileId()
        creationTime: creationTime
        lastEditTime: creationTime
        name: @displayName()
        bounds:
          fixed: true
          left: 0
          right: width - 1
          top: 0
          bottom: height - 1
        pixelFormat: new LOI.Assets.Bitmap.PixelFormat 'flags', 'paletteColor'
        palette:
          _id: macintoshPalette._id
          
      bitmapId = LOI.Assets.Bitmap.documents.insert bitmapData
  
      # Add the bitmap to the project assets.
      PAA.Practice.Project.documents.update projectId,
        $push:
          assets:
            id: assetId
            type: @type()
            bitmapId: bitmapId
        $set:
          lastEditTime: creationTime
          
    solve: ->
      # Load the default image.
      imageFileName = @id().toLowerCase().split('.')[-2..].join('-')
      imageUrl = "/pixelartacademy/pixeltosh/programs/chess/#{imageFileName}.png"
      
      pixels = await new Promise (resolve) =>
        imagePixels = new TutorialBitmap.Resource.ImagePixels imageUrl,
          palette: =>
            LOI.Assets.Palette.documents.findOne name: LOI.Assets.Palette.SystemPaletteNames.Macintosh
        
        Tracker.autorun (computation) =>
          return unless imagePixels.ready()
          computation.stop()
          
          resolve imagePixels.pixels()
          
      @_setPixels pixels
      
    _setPixels: (pixels, action) ->
      assetId = @id()
      bitmap = @bitmap()
      layerAddress = [0]
      action ?= new AM.Document.Versioning.Action assetId
    
      unless bitmap.getLayer [0]
        addLayerAction = new LOI.Assets.Bitmap.Actions.AddLayer assetId, bitmap, []
        AM.Document.Versioning.executePartialAction bitmap, addLayerAction
        action.append addLayerAction
        
      strokeAction = new LOI.Assets.Bitmap.Actions.Stroke assetId, bitmap, layerAddress, pixels
      AM.Document.Versioning.executePartialAction bitmap, strokeAction
      action.append strokeAction
      
      AM.Document.Versioning.executeAction bitmap, bitmap.lastEditTime, action, new Date
  
  class @TwoDimensional
    class @Asset extends Assets.Asset
      @fixedDimensions: -> width: 20, height: 20
      
      @projectClass: -> Chess.Project.TwoDimensional
    
    class @Pawn
      class @White extends TwoDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.TwoDimensional.Pawn.White'
        
        @displayName: -> "White pawn"
        
        @description: -> """
          The simplest of the chess pieces.
          
          When drawing, consider how it will appear against the light and dark chessboard squares. You can change how the squares look from the Theme menu in Chess Academy.
        """
        
        @initialize()
        
        @unlockedPublications: -> [
          'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Publications.SixtyFourSquares.ArtOfTheBoard'
        ]
        
        @unlockedPublicationParts: -> [
          'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Publications.SixtyFourSquares.ArtOfTheBoard.Print'
        ]
      
      class @Black extends TwoDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.TwoDimensional.Pawn.Black'
        
        @displayName: -> "Black pawn"
        
        @description: -> """
          The black variant of the pawn piece.
          
          As a starting point, you can copy the white pawn artwork using the option below. Then, change the coloring or shading to make the piece black.
        """

        @copySourceAssets: -> [Pawn.White]

        @initialize()
    
    class @Knight
      class @White extends TwoDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.TwoDimensional.Knight.White'
        
        @displayName: -> "White knight"
        
        @description: -> """
          The L-moving piece, typically symbolized as a horse.
          
          You can copy the base from another white piece using the options below.
        """

        @copySourceAssets: -> [
          TwoDimensional.Pawn.White
          TwoDimensional.Bishop.White
          TwoDimensional.Rook.White
          TwoDimensional.Queen.White
          TwoDimensional.King.White
        ]

        @initialize()
      
        @unlockedPublicationParts: -> [
          'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Publications.SixtyFourSquares.ArtOfTheBoard.ComputerChess'
        ]
        
      class @Black extends TwoDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.TwoDimensional.Knight.Black'
        
        @displayName: -> "Black knight"
        
        @description: -> """
          The black variant of the knight piece.
          
          You can copy the base from the white knight using the option below.
        """

        @copySourceAssets: -> [Knight.White]

        @initialize()
    
    class @Bishop
      class @White extends TwoDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.TwoDimensional.Bishop.White'
        
        @displayName: -> "White bishop"
        
        @description: -> """
          The diagonal-moving piece, typically distinguished by a pointed top.
          
          You can copy the base from another white piece using the options below.
        """

        @copySourceAssets: -> [
          TwoDimensional.Pawn.White
          TwoDimensional.Knight.White
          TwoDimensional.Rook.White
          TwoDimensional.Queen.White
          TwoDimensional.King.White
        ]

        @initialize()
        
        @unlockedPublicationParts: -> [
          'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Publications.SixtyFourSquares.ArtOfTheBoard.ComputerChess'
        ]
      
      class @Black extends TwoDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.TwoDimensional.Bishop.Black'
        
        @displayName: -> "Black bishop"
        
        @description: -> """
          The black variant of the bishop piece.
          
          You can copy the base from the white bishop using the option below.
        """

        @copySourceAssets: -> [Bishop.White]

        @initialize()
    
    class @Rook
      class @White extends TwoDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.TwoDimensional.Rook.White'
        
        @displayName: -> "White rook"
        
        @description: -> """
          The straight-moving piece, often depicted as a tower.

          You can copy the base from another white piece using the options below.
        """

        @copySourceAssets: -> [
          TwoDimensional.Pawn.White
          TwoDimensional.Knight.White
          TwoDimensional.Bishop.White
          TwoDimensional.Queen.White
          TwoDimensional.King.White
        ]

        @initialize()
      
        @unlockedPublicationParts: -> [
          'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Publications.SixtyFourSquares.ArtOfTheBoard.ComputerChess'
        ]
        
      class @Black extends TwoDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.TwoDimensional.Rook.Black'
        
        @displayName: -> "Black rook"
        
        @description: -> """
          The black variant of the rook piece.
          
          You can copy the base from the white rook using the option below.
        """

        @copySourceAssets: -> [Rook.White]

        @initialize()
    
    class @Queen
      class @White extends TwoDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.TwoDimensional.Queen.White'
        
        @displayName: -> "White queen"
        
        @description: -> """
          The strongest piece in chess, typically represented as a crown.

          You can copy the base from another white piece using the options below.
        """

        @copySourceAssets: -> [
          TwoDimensional.Pawn.White
          TwoDimensional.Knight.White
          TwoDimensional.Bishop.White
          TwoDimensional.Rook.White
          TwoDimensional.King.White
        ]

        @initialize()
        
        @unlockedPublicationParts: -> [
          'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Publications.SixtyFourSquares.ArtOfTheBoard.ComputerChess'
        ]
      
      class @Black extends TwoDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.TwoDimensional.Queen.Black'
        
        @displayName: -> "Black queen"
        
        @description: -> """
          The black variant of the queen piece.

          You can copy the base from the white queen using the option below.
        """

        @copySourceAssets: -> [Queen.White]

        @initialize()
    
    class @King
      class @White extends TwoDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.TwoDimensional.King.White'
        
        @displayName: -> "White king"
        
        @description: -> """
          The piece that needs to be checkmated. It's most often distinguished by a cross on its crown.

          You can copy the base from another white piece using the options below.
        """

        @copySourceAssets: -> [
          TwoDimensional.Pawn.White
          TwoDimensional.Knight.White
          TwoDimensional.Bishop.White
          TwoDimensional.Rook.White
          TwoDimensional.Queen.White
        ]

        @unlockedPublicationParts: -> [
          'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Publications.SixtyFourSquares.ArtOfTheBoard.ComputerChess'
        ]
        
        @initialize()
      
      class @Black extends TwoDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.TwoDimensional.King.Black'
        
        @displayName: -> "Black king"
        
        @description: -> """
          The black variant of the king piece.

          You can copy the base from the white king using the option below.
        """

        @copySourceAssets: -> [King.White]

        @initialize()
  
  class @ThreeDimensional
    class @Asset extends Assets.Asset
      @fixedDimensions: -> width: 16, height: 16
      
      @projectClass: -> Chess.Project.ThreeDimensional
      
    class @Pawn
      class @White extends ThreeDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.ThreeDimensional.Pawn.White'
        
        @displayName: -> "White pawn"
        
        @description: -> """
          The simplest of the chess pieces.
          
          When drawing, consider how it will appear against the light and dark chessboard squares. You can change how the squares look from the Theme menu in Chess Academy.
        """
        
        @initialize()
      
        @unlockedPublications: -> [
          'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Publications.SixtyFourSquares.ArtOfTheBoard'
        ]
        
      class @Black extends ThreeDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.ThreeDimensional.Pawn.Black'
        
        @displayName: -> "Black pawn"
        
        @description: -> """
          The black variant of the pawn piece.
          
          As a starting point, you can copy the white pawn artwork using the option below. Then, change the coloring or shading to make the piece black.
        """

        @copySourceAssets: -> [Pawn.White]

        @initialize()
    
    class @Knight
      class @White extends ThreeDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.ThreeDimensional.Knight.White'
        
        @displayName: -> "White knight"
        
        @description: -> """
          The L-moving piece, typically symbolized as a horse.
          
          You can copy the base from another white piece using the options below.
        """

        @copySourceAssets: -> [
          ThreeDimensional.Pawn.White
          ThreeDimensional.Bishop.White
          ThreeDimensional.Rook.White
          ThreeDimensional.Queen.White
          ThreeDimensional.King.White
        ]

        @initialize()
      
      class @Black extends ThreeDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.ThreeDimensional.Knight.Black'
        
        @displayName: -> "Black knight"
        
        @description: -> """
          The black variant of the knight piece.

          You can copy the base from the white knight using the option below.
        """

        @copySourceAssets: -> [Knight.White]

        @initialize()
    
    class @Bishop
      class @White extends ThreeDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.ThreeDimensional.Bishop.White'
        
        @displayName: -> "White bishop"
        
        @description: -> """
          The diagonal-moving piece, typically distinguished by a pointed top.
          
          You can copy the base from another white piece using the options below.
        """

        @copySourceAssets: -> [
          ThreeDimensional.Pawn.White
          ThreeDimensional.Knight.White
          ThreeDimensional.Rook.White
          ThreeDimensional.Queen.White
          ThreeDimensional.King.White
        ]

        @initialize()
      
      class @Black extends ThreeDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.ThreeDimensional.Bishop.Black'
        
        @displayName: -> "Black bishop"
        
        @description: -> """
          The black variant of the bishop piece.
          
          You can copy the base from the white bishop using the option below.
        """

        @copySourceAssets: -> [Bishop.White]

        @initialize()
    
    class @Rook
      class @White extends ThreeDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.ThreeDimensional.Rook.White'
        
        @displayName: -> "White rook"
        
        @description: -> """
          The straight-moving piece, often depicted as a tower.
          
          You can copy the base from another white piece using the options below.
        """

        @copySourceAssets: -> [
          ThreeDimensional.Pawn.White
          ThreeDimensional.Knight.White
          ThreeDimensional.Bishop.White
          ThreeDimensional.Queen.White
          ThreeDimensional.King.White
        ]

        @initialize()
      
      class @Black extends ThreeDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.ThreeDimensional.Rook.Black'
        
        @displayName: -> "Black rook"
        
        @description: -> """
          The black variant of the rook piece.
          
          You can copy the base from the white rook using the option below.
        """

        @copySourceAssets: -> [Rook.White]

        @initialize()
    
    class @Queen
      class @White extends ThreeDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.ThreeDimensional.Queen.White'
        
        @displayName: -> "White queen"
        
        @description: -> """
          The strongest piece in chess, typically represented as a crown.
          
          You can copy the base from another white piece using the options below.
        """

        @copySourceAssets: -> [
          ThreeDimensional.Pawn.White
          ThreeDimensional.Knight.White
          ThreeDimensional.Bishop.White
          ThreeDimensional.Rook.White
          ThreeDimensional.King.White
        ]

        @initialize()
      
      class @Black extends ThreeDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.ThreeDimensional.Queen.Black'
        
        @displayName: -> "Black queen"
        
        @description: -> """
          The black variant of the queen piece.
          
          You can copy the base from the white queen using the option below.
        """

        @copySourceAssets: -> [Queen.White]

        @initialize()
    
    class @King
      class @White extends ThreeDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.ThreeDimensional.King.White'
        
        @displayName: -> "White king"
        
        @description: -> """
          The piece that needs to be checkmated. It's most often distinguished by a cross on its crown.
          
          You can copy the base from another white piece using the options below.
        """

        @copySourceAssets: -> [
          ThreeDimensional.Pawn.White
          ThreeDimensional.Knight.White
          ThreeDimensional.Bishop.White
          ThreeDimensional.Rook.White
          ThreeDimensional.Queen.White
        ]

        @initialize()
      
      class @Black extends ThreeDimensional.Asset
        @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.ThreeDimensional.King.Black'
        
        @displayName: -> "Black king"
        
        @description: -> """
          The black variant of the king piece.
          
          You can copy the base from the white king using the option below.
        """

        @copySourceAssets: -> [King.White]

        @initialize()
