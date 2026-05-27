AE = Artificial.Everywhere
AB = Artificial.Base
PAA = PixelArtAcademy

class PAA.Pixeltosh.Programs.Chess extends PAA.Pixeltosh.Program
  # TODO: boardDisplayType: enum whether the camera should be 3D or 3D
  # displayBoardCoordinates: boolean whether to display the files and ranks along the border of the board
  # chessSet2D: the project ID of the currently chosen 2D chess set
  # TODO: chessSet3D: the project ID of the currently chosen 3D chess set
  # currency: number of currency the player has
  # ownedPieceTypeCounts: how many pieces did the player purchase
  #   {pieceType}: number of pieces of this type the player owns
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess'
  @register @id()
  
  @version: -> '0.1.0'
  
  @fullName: -> "Chess Academy"
  @description: ->
    "
      Learn how to play chess.
    "
  
  @slug: -> 'chess'
  
  @initialize()
  
  @chessSet2D: -> @state('chessSet2D') or @Project.TwoDimensional.state 'activeProjectId'
  
  constructor: ->
    super arguments...
    
    # Prepare all reactive fields.
    @interfaceManager = new ReactiveField null
    @gameManager = new ReactiveField null
    @lessonManager = new ReactiveField null
    
  load: ->
    super arguments...

    # Initialize components.
    @interfaceManager new @constructor.InterfaceManager @
    @gameManager new @constructor.GameManager @
    @lessonManager new @constructor.LessonManager @
    
    # Subscribe to the macintosh palette.
    @_macintoshPaletteSubscription = LOI.Assets.Palette.forName.subscribeContent LOI.Assets.Palette.SystemPaletteNames.Macintosh
    
  unload: ->
    @interfaceManager()?.destroy()
    @gameManager()?.destroy()
    @lessonManager()?.destroy()
    
    @interfaceManager null
    @gameManager null
    @lessonManager null
    
    @_macintoshPaletteSubscription.stop()
  
  onBackButton: ->
    # Going back closes the shop.
    interfaceManager = @interfaceManager()
    
    if interfaceManager.shopIsOpen()
      interfaceManager.closeShop()

      # Inform that we've handled the back button.
      return true
      
    # Going back returns to the menu.
    if not interfaceManager.inMenu()
      interfaceManager.enterScreen @constructor.InterfaceManager.Screens.Menu
      
      # Inform that we've handled the back button.
      return true
    
  menuItems: -> @constructor.Interface.createMenuItems()

  shortcuts: -> @constructor.Interface.createShortcuts()
