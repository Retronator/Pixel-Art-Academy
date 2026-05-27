AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Babel
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lesson.Step extends AM.Component
  @initialize: ->
    @register @id()
    
    # On the server, after document observers are started, perform initialization.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty
        
        # Create this instruction's translated names.
        translationNamespace = @id()
        
        for property in ['message']
          continue unless value = @[property]()
          AB.createTranslation translationNamespace, property, value
          
  template: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lesson.Step'
  
  constructor: (@lesson) ->
    super arguments...
    
    @_id = @id()
  
  id: -> @constructor.id()
  
  message: -> @translate('message').text
  messageTranslation: -> @translation 'message'
  
  completed: -> throw new AE.NotImplementedException "A step must specify when it is completed."

  markup: -> # Override to provide chessboard markup.
  
  gameState: -> @lesson.lessonManager.gameState()

  chessboard: -> @lesson.lessonManager.getChessboard()
