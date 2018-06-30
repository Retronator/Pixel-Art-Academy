LOI = LandsOfIllusions

class LOI.Adventure.Chapter extends LOI.Adventure.Section
  @register 'LandsOfIllusions.Adventure.Chapter'
  template: -> 'LandsOfIllusions.Adventure.Chapter'

  @fullName: ->
    # Unlike sections, chapters do need a name so we need to revert the override from the section class.
    throw new AE.NotImplementedException

  @scenes: -> [] # Override to provide any scenes that are always active in a chapter.

  @sections: -> throw new AE.NotImplementedException

  timelineId: ->
    # By default we use the timeline of the episode.
    @constructor.timelineId() or @episode.timelineId()

  constructor: (@options) ->
    # Set the episode and chapter before calling super, because super executes active, which needs these fields.
    @episode = @options.parent
    @previousChapter = @options.previousChapter

    super

    @sections = new ComputedField =>
      # Create sections JIT when chapter becomes active.
      return [] unless @_active()

      Tracker.nonreactive =>
        console.log "Created sections for chapter", @id() if LOI.debug

        for sectionClass in @constructor.sections()
          new sectionClass parent: @
    ,
      true

  destroy: ->
    super

    section.destroy() for section in @sections()

  getSection: (sectionClassOrId) ->
    sectionId = _.thingId sectionClassOrId

    _.find @sections(), (section) => section.id() is sectionId

  started: ->
    # We use a convention of sending in a previous chapter which is used as a trigger for this chapter to start. When
    # no previous chapter is set, the chapter automatically starts when the start section of the episode is finished.
    if @previousChapter then @previousChapter.finished() else @episode.startSection.finished()

  active: ->
    # Unlike a section, a chapter stays active forever to preserve inventory
    # and other permanent changes, as well as access to unfinished sections.
    @_activeAfterStarted()
    
  accessRequirement: ->
    # By default, chapters share the access requirement of the episode.
    @episode.accessRequirement()

  currentSections: ->
    section for section in @sections() when section.active()

  ready: ->
    # Chapter is ready when all its sections are ready.
    conditions = _.flattenDeep [
      super
      (section.ready() for section in @sections())
    ]

    _.every conditions

  showChapterTitle: (options = {}) ->
    # Create new storyline title.
    chapterTitle = new LOI.Components.StorylineTitle _.extend {}, options,
      chapter: @

    LOI.adventure.showActivatableModalDialog
      dialog: chapterTitle
