AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

Pinball = PAA.Pixeltosh.Programs.Pinball
Chess = PAA.Pixeltosh.Programs.Chess

class LM.PixelArtFundamentals.Fundamentals extends LM.Chapter
  # openedPinballMachine: boolean whether the player has opened the Pinball Machine file.
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals'
  
  @fullName: -> "Pixel art fundamentals"
  @number: -> 1
  
  @sections: -> []

  @scenes: -> [
    @Apps
    @TutorialsDrawing
    @ChallengesDrawing
    @PixeltoshPrograms
    @PixeltoshFiles
    @Workbench
    @MusicTapes
    @Publications
    @Publications.Parts
    @Pico8Cartridges
  ]

  @courses: -> [
    LM.PixelArtFundamentals.Fundamentals.Content.Course
  ]

  @initialize()

  constructor: ->
    super arguments...
    
    # Create the pinball project when the application is enabled.
    @_createPinballProjectAutorun = Tracker.autorun (computation) =>
      return unless LOI.adventure.gameStateAvailable()
      return unless LM.PixelArtFundamentals.pinballEnabled()
      return if Pinball.Project.state 'activeProjectId'
      
      Pinball.Project.start()

    # Create the chess projects when the content is unlocked.
    @_createChess2DProjectAutorun = Tracker.autorun (computation) =>
      return unless LOI.adventure.gameStateAvailable()
      return unless LM.PixelArtFundamentals.Fundamentals.Content.Projects.Chess.TwoDimensional.getAdventureInstance().status() is LM.Content.Status.Unlocked
      return if Chess.Project.TwoDimensional.state 'activeProjectId'
      
      Chess.Project.TwoDimensional.start()
    
    # Create assets for the pieces the player owns.
    @_createChessAssetsAutorun = Tracker.autorun (computation) =>
      return unless LOI.adventure.gameStateAvailable()
      return unless projectId = Chess.Project.TwoDimensional.state 'activeProjectId'
      return unless project = PAA.Practice.Project.documents.findOne projectId
      return unless ownedPieceTypeCounts = Chess.state 'ownedPieceTypeCounts'
      
      for pieceType, count of ownedPieceTypeCounts when count
        # Add the white piece asset as soon as a piece is owned.
        whiteAsset = Chess.Assets.TwoDimensional[pieceType].White
        whiteAssetId = whiteAsset.id()
        whiteAssetData = _.find project.assets, (asset) => asset.id is whiteAssetId
        
        unless whiteAssetData
          whiteAsset.addToProject projectId
          continue
        
        # Add the black piece after the white piece asset is drawn.
        blackAsset = Chess.Assets.TwoDimensional[pieceType].Black
        blackAssetId = blackAsset.id()
        continue if _.find project.assets, (asset) => asset.id is blackAssetId

        continue unless whiteBitmap = LOI.Assets.Bitmap.versionedDocuments.getDocumentForId whiteAssetData.bitmapId
        continue unless whiteBitmap.historyPosition
        
        blackAsset.addToProject projectId
  
  destroy: ->
    super arguments...
    
    @_createPinballProjectAutorun.stop()
    @_createChess2DProjectAutorun.stop()
    @_createChessAssetsAutorun.stop()
