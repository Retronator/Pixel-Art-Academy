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
  
  constructor: ->
    super arguments...
    
    # Prepare all reactive fields.
    @interfaceManager = new ReactiveField null
    @gameManager = new ReactiveField null
    
    @projectId2D = new AE.LiveComputedField =>
      @state('chessSet2D') or @constructor.Project.TwoDimensional.state('activeProjectId')
    
  destroy: ->
    super arguments...
    
    @projectId2D.stop()
    
  load: ->
    super arguments...

    # Initialize components.
    @interfaceManager new @constructor.InterfaceManager @
    @gameManager new @constructor.GameManager @
    
  unload: ->
    @interfaceManager()?.destroy()
    @gameManager()?.destroy()
    
    @interfaceManager null
    @gameManager null
  
  menuItems: -> @constructor.Interface.createMenuItems()
