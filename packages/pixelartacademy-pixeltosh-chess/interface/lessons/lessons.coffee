AM = Artificial.Mirage
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Lessons extends AM.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Lessons'
  @register @id()

  onCreated: ->
    super arguments...

    @os = @ancestorComponentOfType PAA.Pixeltosh.OS
    @chess = @os.getProgram Chess

  scrollbars: ->
    vertical:
      enabled: true
  
  categories: -> @chess.lessonManager()?.availableCategories()

  lessonStatusClass: ->
    lesson = @currentData()
    return unless gameManager = @chess.gameManager()

    'available'

  lessonCursorAttribute: ->
    lesson = @currentData()
    'data-cursor': 'pointer' #if @chess.gameManager().lessonAvailable lesson

  activeLesson: ->
    @currentData() is @chess.gameManager().activeLesson()

  events: ->
    super(arguments...).concat
      'click .lesson': @onClickLesson

  onClickLesson: (event) ->
    lesson = @currentData()

    @chess.lessonManager().startLesson lesson
    @chess.interfaceManager().enterScreen Chess.InterfaceManager.Screens.Lesson
