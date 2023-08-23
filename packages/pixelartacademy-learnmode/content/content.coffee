AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Content
  @Status =
    Unavailable: 'Unavailable'
    Locked: 'Locked'
    Unlocked: 'Unlocked'

  @Tags =
    WIP: 'WIP'
    Future: 'Future'
    
  @_contentClassesById = {}
  @_contentClassesUpdatedDependency = new Tracker.Dependency

  @getClassForId: (id) ->
    @_contentClassesUpdatedDependency.depend()
    @_contentClassesById[id]

  @removeClassForId: (id) ->
    delete @_contentClassesById[id]
    @_contentClassesUpdatedDependency.depend()

  # Id string for this content used to identify the content in code.
  @id: -> throw new AE.NotImplementedException "You must specify content's id."

  # The type that identifies the content class individual tasks inherit from.
  @type: -> 'Content'

  # String to represent the course in the UI. Note that we can't use
  # 'name' since it's an existing property holding the class name.
  @displayName: -> throw new AE.NotImplementedException "You must specify the content name."

  # Override to provide a string that shortly describes the content as seen in the courses preview screen.
  @description: -> null

  # Override to provide tags for this course.
  @tags: -> []

  # Optional instructions how to unlock this content.
  @unlockInstructions: -> null

  # Override to provide any children content classes that are part of this content.
  @contents: -> []

  @initialize: ->
    # Store content class by ID.
    @_contentClassesById[@id()] = @
    @_contentClassesUpdatedDependency.changed()

    # On the server, after document observers are started, perform initialization.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty

        # Create this avatar's translated names.
        translationNamespace = @id()
        for property in ['displayName', 'description', 'unlockInstructions']
          value = @[property]()
          AB.createTranslation translationNamespace, property, value if value?

  @getAdventureInstanceForId: (contentId) ->
    for episode in LOI.adventure.episodes()
      for chapter in episode.chapters
        for content in chapter.contents
          return content if content.id() is contentId

    console.warn "Unknown content requested.", contentId
    null

  constructor: (@parent, @options = {}) ->
    @course = @options.course

    # By default the content is related to the current profile.
    @options.profileId ?= => LOI.adventure.profileId()

    # Create all the children contents.
    @_contents = []

    for contentClass in @constructor.contents()
      content = new contentClass @, @options
      @_contents.push content

    # Subscribe to this content's translations.
    translationNamespace = @id()
    @_translationSubscription = AB.subscribeNamespace translationNamespace

  destroy: ->
    @_translationSubscription.stop()
    @progress.destroy()

  id: -> @constructor.id()
  type: -> @constructor.type()

  displayName: -> AB.translate(@_translationSubscription, 'displayName').text
  displayNameTranslation: -> AB.translation @_translationSubscription, 'displayName'
  
  description: ->
    translated = AB.translate @_translationSubscription, 'description'
    if translated.language then translated.text else null
  
  descriptionTranslation: -> AB.existingTranslation @_translationSubscription, 'description'

  tags: -> @constructor.tags()
  
  unlockInstructions: ->
    return unless @constructor.unlockInstructions()
    AB.translate(@_translationSubscription, 'unlockInstructions').text

  unlockInstructionsTranslation: ->
    return unless @constructor.unlockInstructions()
    AB.translation @_translationSubscription, 'unlockInstructions'

  contents: -> @_contents

  allContents: -> _.flatten [@, (content.allContents() for content in @_contents)...]

  status: -> throw new AE.NotImplementedException "Content must provide its status."
  available: -> @parent.unlocked() and @status() isnt @constructor.Status.Unavailable
  unlocked: -> @parent.unlocked() and @status() is @constructor.Status.Unlocked
  locked: -> @parent.locked() or @status() is @constructor.Status.Locked

  completed: ->
    return unless @unlocked()
    @progress.completed()

  completedRatio: ->
    return 0 unless @unlocked()
    @progress.completedRatio()

  requiredCompletedRatio: ->
    return unless @unlocked()
    return 1 if @progress.completed()
    @progress.requiredCompletedRatio?()

  # How deep this content is below the course (which is at depth 1).
  depth: ->
    content = @
    depth = 1

    while content not instanceof LM.Content.Course
      content = content.parent
      depth++

    depth
