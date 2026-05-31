AE = Artificial.Everywhere
AB = Artificial.Babel
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lesson
  # completedCount: integer, how many times the player completed a lesson.
  @_lessonClasses = []
  
  @getClassesForCategory: (categoryId) -> _.filter @_lessonClasses, (lessonClass) => lessonClass.category().id() is categoryId

  # Id string for this lesson used to identify the lesson in code.
  @id: -> throw new AE.NotImplementedException "You must specify lesson's id."

  # String to represent the lesson in the UI. Note that we can't use
  # 'name' since it's an existing property holding the class name.
  @displayName: -> throw new AE.NotImplementedException "You must specify the lesson name."
  
  @category: -> throw new AE.NotImplementedException "You must specify the lesson category."
  
  @startingPosition: -> throw new AE.NotImplementedException "You must specify where the pieces start."

  @startingGameState: -> Chess.GameState.fromPosition @startingPosition()
  
  @steps: -> throw new AE.NotImplementedException "You must specify the lesson steps."
  
  @additionalRequiredPieces: -> [] # Override if this lesson requires pieces that are not part of the starting game state.

  @initialize: ->
    @_lessonClasses.push @

    @stateAddress = new LOI.StateAddress "things.#{@id()}"
    @state = new LOI.StateObject address: @stateAddress
    
    # On the server, after document observers are started, perform initialization.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty

        # Create this lesson's translated names.
        translationNamespace = @id()
        AB.createTranslation translationNamespace, property, @[property]() for property in ['displayName']

  constructor: (@lessonManager) ->
    @stateAddress = @constructor.stateAddress
    @state = @constructor.state
    
    # Subscribe to this lesson's translations.
    translationNamespace = @id()
    @_translationSubscription = AB.subscribeNamespace translationNamespace
    
    # Initialize the steps.
    @steps = (new stepClass @ for stepClass in @constructor.steps())

  destroy: ->
    @_translationSubscription.stop()

  id: -> @constructor.id()
  startingGameState: -> @constructor.startingGameState()

  displayName: -> AB.translate(@_translationSubscription, 'displayName').text
  displayNameTranslation: -> AB.translation @_translationSubscription, 'displayName'

  completedCount: -> @state('completedCount') or 0
  
  requiredPieceTypeCounts: ->
    whitePieces = @startingGameState().getPiecesOfColor Chess.Piece.Colors.White
    pieceTypeCounts = _.countBy whitePieces, (piece) => piece.type
    
    for pieceType in @constructor.additionalRequiredPieces()
      pieceTypeCounts[pieceType] = (pieceTypeCounts[pieceType] or 0) + 1
    
    pieceTypeCounts
  
  available: ->
    return unless gameManager = @lessonManager.chess.gameManager()

    for pieceType, count of @requiredPieceTypeCounts()
      return false if count > gameManager.ownedPiecesCount pieceType
      
    true
  
  aiMove: -> # Override if this lesson is played against the computer.
