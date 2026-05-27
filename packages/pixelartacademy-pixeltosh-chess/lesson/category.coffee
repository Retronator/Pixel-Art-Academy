AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lesson.Category
  @_categoryClasses = []

  @getClasses: -> @_categoryClasses

  # Id string for this category used to identify the category in code.
  @id: -> throw new AE.NotImplementedException "You must specify lesson category's id."

  # String to represent the category in the UI. Note that we can't use
  # 'name' since it's an existing property holding the class name.
  @displayName: -> throw new AE.NotImplementedException "You must specify the lesson category name."

  @initialize: ->
    @_categoryClasses.push @
    
    # On the server, after document observers are started, perform initialization.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty

        # Create this category's translated names.
        translationNamespace = @id()
        AB.createTranslation translationNamespace, property, @[property]() for property in ['displayName']

  constructor: (@lessonManager) ->
    # Subscribe to this category's translations.
    translationNamespace = @id()
    @_translationSubscription = AB.subscribeNamespace translationNamespace
    
    # Instantiate all lessons in this category.
    lessonClasses = Chess.Lesson.getClassesForCategory @id()
    
    @lessons = (new lessonClass @lessonManager for lessonClass in lessonClasses)

  destroy: ->
    @_translationSubscription.stop()
    
    lesson.destroy() for lesson in @lessons

  id: -> @constructor.id()

  displayName: -> AB.translate(@_translationSubscription, 'displayName').text
  displayNameTranslation: -> AB.translation @_translationSubscription, 'displayName'
  
  available: -> throw new AE.NotImplementedException "You must specify whether this category is available."
