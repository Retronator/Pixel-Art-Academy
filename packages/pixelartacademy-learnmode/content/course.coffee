AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Content.Course
  @Status =
    Unavailable: 'Unavailable'
    Available: 'Available'
    Purchased: 'Purchased'

  @_courseClassesById = {}
  @_courseClassesUpdatedDependency = new Tracker.Dependency

  @getClassForId: (id) ->
    @_courseClassesUpdatedDependency.depend()
    @_courseClassesById[id]

  @removeClassForId: (id) ->
    delete @_courseClassesById[id]
    @_courseClassesUpdatedDependency.depend()

  @getClasses: ->
    @_courseClassesUpdatedDependency.depend()
    _.values @_courseClassesById

  # Id string for this course used to identify the course in code.
  @id: -> throw new AE.NotImplementedException "You must specify course's id."

  # String to represent the course in the UI. Note that we can't use
  # 'name' since it's an existing property holding the class name.
  @displayName: -> throw new AE.NotImplementedException "You must specify the course name."

  # Override to provide a string that shortly describes the content as seen in the courses preview/progress screen.
  @description: -> throw new AE.NotImplementedException "You must specify the course description."

  # Override to provide tags for this course.
  @tags: -> []

  # Override to provide content classes that are included in this course.
  @contents: -> []

  @initialize: ->
    # Store course class by ID.
    @_courseClassesById[@id()] = @
    @_courseClassesUpdatedDependency.changed()

    # On the server, after document observers are started, perform initialization.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty

        # Create this course's translated names.
        translationNamespace = @id()
        AB.createTranslation translationNamespace, property, @[property]() for property in ['displayName', 'description']

  constructor: (@options = {}) ->
    # By default the content is related to the current profile.
    @options.profileId ?= => LOI.adventure.profileId()
    @options.course = @

    # Create all the contents.
    @_contents = []

    for contentClass in @constructor.contents()
      content = new contentClass @, @options
      @_contents.push content

    # Subscribe to this course's translations.
    translationNamespace = @id()
    @_translationSubscription = AB.subscribeNamespace translationNamespace

    @progress = new LM.Content.Progress.ContentProgress content: @

  destroy: ->
    @_translationSubscription.stop()
    @progress.destroy()

    content.destroy() for content in @_contents

  id: -> @constructor.id()
  type: -> 'Course'

  displayName: -> AB.translate(@_translationSubscription, 'displayName').text
  displayNameTranslation: -> AB.translation @_translationSubscription, 'displayName'

  description: -> AB.translate(@_translationSubscription, 'description').text
  descriptionTranslation: -> AB.translation @_translationSubscription, 'description'

  tags: -> @constructor.tags()

  contents: -> @_contents

  allContents: -> _.flatten (content.allContents() for content in @_contents)

  available: -> true # TODO: Add purchased status
  unlocked: -> true # TODO: Add purchased status
  completed: -> @progress.completed()
  completedRatio: -> @progress.completedRatio()

  # The course is at the top of the content hierarchy.
  depth: -> 1
