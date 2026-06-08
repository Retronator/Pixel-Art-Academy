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
    
    @hoveredLesson = new ReactiveField null
    
  onRendered: ->
    super arguments...
    
    @$lessons = @$('.pixelartacademy-pixeltosh-programs-chess-interface-lessons')

  scrollbars: ->
    vertical:
      enabled: true
  
  categories: -> @chess.lessonManager()?.availableCategories()

  lessonLockedClass: ->
    lesson = @currentData()
    'locked' unless lesson.available()
  
  lessonCompletedClass: ->
    lesson = @currentData()
    completedCount = lesson.completedCount()

    if completedCount is 1
      'completed'
      
    else if completedCount > 1
      'completed twice'

  lessonCursorAttribute: ->
    lesson = @currentData()
    'data-cursor': 'pointer' if lesson.available()

  activeLesson: ->
    @currentData() is @chess.gameManager()?.activeLesson()
  
  lockedLessonInfo: ->
    return unless hoveredLesson = @hoveredLesson()
    lesson = hoveredLesson.lesson
    return if lesson.available()
    
    requiredPieceTypes = for pieceType, count of lesson.requiredPieceTypeCounts()
      type: pieceType
      ownedCount: Chess.ownedPiecesCount pieceType
      requiredCount: count
      
    _.remove requiredPieceTypes, (requiredPieceType) => requiredPieceType.ownedCount >= requiredPieceType.requiredCount
    
    requiredPieceTypes: requiredPieceTypes
    topStyle:
      top: hoveredLesson.top

  events: ->
    super(arguments...).concat
      'click .lesson': @onClickLesson
      'pointerenter .lesson': @onPointerEnterLesson
      'pointerleave .lesson': @onPointerLeaveLesson

  onClickLesson: (event) ->
    lesson = @currentData()
    return unless lesson.available()

    @chess.lessonManager().startLesson lesson
    @chess.interfaceManager().enterScreen Chess.InterfaceManager.Screens.Lesson
  
  onPointerEnterLesson: (event) ->
    lesson = @currentData()
    
    # Calculate vertical offset between lesson element and scroll container
    top = $(event.currentTarget).offset().top - @$lessons.offset().top
    
    @hoveredLesson {lesson, top}
  
  onPointerLeaveLesson: (event) ->
    @hoveredLesson null
