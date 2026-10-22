AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Project extends PAA.Practice.Project.Thing
  # Project document fields
  # interfaceTheme: enum, which theme to display the program interface in when this project is active
  # chessboardTheme: enum, which theme to display the chessboard in when this project is active
  @iconUrl: -> @versionedUrl "/pixelartacademy/pixeltosh/programs/chess/icon-project.png"
  @program: -> Chess

  @assetsProviderClass: -> Chess.Project.AssetsProvider

  @visible: -> Chess.ownedPiecesCount() > 0

  @editable: -> PAA.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Chess.completed()
  
  @nameAssetsProviderInstructions: -> "Name your chess set"
  
  @assetsProviderNamePlaceholder: -> "Enter chess set name"
  
  @defaultAssetsProviderName: -> "My chess set"
  
  @newAssetsProviderPlaceholder: -> "Create new chess set"
  
  @editAssetsProviderInstructions: -> "Edit chess set"
  
  @deleteAssetsProviderConfirmation: -> "Are you sure you want to delete this chess set? This cannot be undone."
