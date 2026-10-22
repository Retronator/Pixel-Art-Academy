AE = Artificial.Everywhere
AEc = Artificial.Echo
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.Programs.Chess extends PAA.Pixeltosh.Program
  # boardDisplayType: enum whether the camera should be 2D or 3D
  # displayBoardCoordinates: boolean whether to display the files and ranks along the border of the board
  # autoPromotion: boolean whether to automatically promote a pawn to a queen
  # autoFlipBoard: boolean whether to automatically orient the board for the human player on turn
  # audioBoard: boolean whether to play board interaction sounds
  # audioVoice: boolean whether Pixeltosh should make spoken announcements
  # interfaceTheme: enum for a fallback interface theme when no chess set is selected
  # projectId2D: optional project ID of the currently chosen 2D chess set, activeProjectId otherwise
  # TODO: projectId3D: optional project ID of the currently chosen 3D chess set, activeProjectId otherwise
  # currency: number of currency the player has
  # ownedPieceTypeCounts: how many pieces did the player purchase
  #   {pieceType}: number of pieces of this type the player owns
  # pendingRewards: array of rewards that the player has not yet received
  #   id: identifier of the reward
  #   data: any additional data needed to display the reward or calculate its value
  # playStarted: boolean whether a full game was ever initiated
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
  
  # State fields
  
  @BoardDisplayTypes:
    TwoDimensional: 'TwoDimensional'
    ThreeDimensional: 'ThreeDimensional'

  @ChessboardThemes:
    Newspaper: 'Newspaper'
    Light: 'Light'
    Contrast: 'Contrast'
    Dark: 'Dark'

  @InterfaceThemes:
    Light: 'Light'
    Dark: 'Dark'
  
  @DrawTypes =
    Stalemate: 'Stalemate'
    FiftyMoveRule: 'FiftyMoveRule'
    InsufficientMaterial: 'InsufficientMaterial'
    ThreefoldRepetition: 'ThreefoldRepetition'
    
  @boardDisplayType = @state.field 'boardDisplayType', default: @BoardDisplayTypes.TwoDimensional
  @displayBoardCoordinates = @state.field 'displayBoardCoordinates', default: false
  @autoPromotion = @state.field 'autoPromotion', default: false
  @autoFlipBoard = @state.field 'autoFlipBoard', default: true
  @audioBoard = @state.field 'audioBoard', default: true
  @audioVoice = @state.field 'audioVoice', default: true
  @interfaceTheme = @state.field 'interfaceTheme', default: @InterfaceThemes.Light
  
  @projectId2D: -> @state('projectId2D') or @Project.TwoDimensional.state 'activeProjectId'
  @projectId3D: -> @state('projectId3D') or @Project.ThreeDimensional.state 'activeProjectId'

  @activateProject: (project) ->
    projectClass = _.find  [@Project.TwoDimensional, @Project.ThreeDimensional], (projectClass) => projectClass.id() is project.type
    projectIdField = if projectClass is @Project.TwoDimensional then 'projectId2D' else 'projectId3D'

    if project?.profileId is LOI.adventure.profileId()
      # This is a player project. Activate it.
      projectClass.state 'activeProjectId', project._id
      @state projectIdField, null
      
    else
      # This is a public project. Select it in the state.
      @state projectIdField, project._id

    # Turn on the display type that will showcase this project.
    boardDisplayType = if projectClass is @Project.TwoDimensional then @BoardDisplayTypes.TwoDimensional else @BoardDisplayTypes.ThreeDimensional
    @state 'boardDisplayType', boardDisplayType
    
  @currentProjectId: ->
    switch @boardDisplayType()
      when @BoardDisplayTypes.TwoDimensional then @projectId2D()
      when @BoardDisplayTypes.ThreeDimensional then @projectId3D()

  @currentProject: ->
    return unless projectId = @currentProjectId()
    PAA.Practice.Project.documents.findOne projectId
  
  @currency = @state.field 'currency', default: 0
  @ownedPieceTypeCounts = @state.field 'ownedPieceTypeCounts', default: {}
  @pendingRewards = @state.field 'pendingRewards', default: []
  
  # Helpers
  
  @ownedPiecesCount: (pieceType) ->
    counts = @ownedPieceTypeCounts()
    
    if pieceType
      counts[pieceType] or 0
    
    else
      _.sum _.values counts
    
  @activeAssetIsDrawn: (pieceType, color) ->
    switch @state('boardDisplayType')
      when @BoardDisplayTypes.TwoDimensional then @_assetIsDrawn2D pieceType, color
      when @BoardDisplayTypes.ThreeDimensional then @_assetIsDrawn3D pieceType, color
      
  @assetIsDrawnInEitherDimension: (pieceType, color) ->
    @_assetIsDrawn2D(pieceType, color) or @_assetIsDrawn3D(pieceType, color)
    
  @_assetIsDrawn2D: (pieceType, color) ->
    return unless project = PAA.Practice.Project.documents.findOne @projectId2D()
    assetId = Chess.Assets.TwoDimensional[pieceType][color].id()
    @_assetIsDrawnInProject project, assetId
  
  @_assetIsDrawn3D: (pieceType, color) ->
    return unless project = PAA.Practice.Project.documents.findOne @projectId3D()
    assetId = Chess.Assets.ThreeDimensional[pieceType][color].id()
    @_assetIsDrawnInProject project, assetId
    
  @_assetIsDrawnInProject: (project, assetId) ->
    return unless asset = _.find project.assets, (asset) => asset.id is assetId
    return unless bitmap = LOI.Assets.Bitmap.documents.findOne asset.bitmapId
    bitmap.historyPosition or 0
  
  @pawnAssetMissing: ->
    return unless @currentProject()
    return unless @ownedPiecesCount Chess.Piece.Types.Pawn
    not @activeAssetIsDrawn Chess.Piece.Types.Pawn, Chess.Piece.Colors.White
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    variables:
      pickUp:
        valueType: AEc.ValueTypes.Trigger
        throttle: 100
      drop:
        valueType: AEc.ValueTypes.Trigger
        throttle: 100
      capture:
        valueType: AEc.ValueTypes.Trigger
        throttle: 100
      promote:
        valueType: AEc.ValueTypes.Trigger
        throttle: 100
      enabled: AEc.ValueTypes.Boolean

  constructor: ->
    super arguments...
    
    @ownedPieceTypeCounts = @constructor.ownedPieceTypeCounts
    @currency = @constructor.currency
    @pendingRewards = @constructor.pendingRewards
    
    # Prepare all reactive fields.
    @interfaceManager = new ReactiveField null
    @gameManager = new ReactiveField null
    @lessonManager = new ReactiveField null
    @rewardsManager = new ReactiveField null
    @audioManager = new ReactiveField null
    
  load: (file) ->
    super arguments...

    @openFile file if file

    # Initialize components.
    @interfaceManager new @constructor.InterfaceManager @
    @gameManager new @constructor.GameManager @
    @lessonManager new @constructor.LessonManager @
    @rewardsManager new @constructor.RewardsManager @
    @audioManager new @constructor.AudioManager @
    
    # Subscribe to the macintosh palette.
    @_macintoshPaletteSubscription = LOI.Assets.Palette.forName.subscribeContent LOI.Assets.Palette.SystemPaletteNames.Macintosh
    
  unload: ->
    super arguments...

    @interfaceManager()?.destroy()
    @gameManager()?.destroy()
    @lessonManager()?.destroy()
    @rewardsManager()?.destroy()
    @audioManager()?.destroy()
    
    @interfaceManager null
    @gameManager null
    @lessonManager null
    @rewardsManager null
    @audioManager null
    
    @_macintoshPaletteSubscription?.stop()

  openFile: (file) ->
    projectId = file.data().projectId
    project = PAA.Practice.Project.documents.findOne projectId
    @constructor.activateProject project
  
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

    # Going back returns from the chess set choice back to the board display choice.
    if interfaceManager.choosingChessSet() and interfaceManager.chessSetChoiceIsOpen()
      interfaceManager.backToBoardDisplayChoice()
      
      # Inform that we've handled the back button.
      return true
    
  menuItems: -> @constructor.Interface.createMenuItems()

  shortcuts: -> @constructor.Interface.createShortcuts()
