LOI = LandsOfIllusions

class LOI.Adventure.Chapter extends LOI.Adventure.Section
  @register 'LandsOfIllusions.Adventure.Chapter'
  template: -> 'LandsOfIllusions.Adventure.Chapter'

  @fullName: ->
    # Unlike sections, chapters do need a name so we need to revert the override from the section class.
    throw new AE.NotImplementedException

  @scenes: -> [] # Override to provide any scenes that are always active in a chapter.

  @number: -> throw new AE.NotImplementedException
  number: -> @constructor.number()

  @sections: -> throw new AE.NotImplementedException

  @timelineId: -> # Override to set a default timeline for scenes.
  timelineId: ->
    # By default we use the timeline of the episode.
    @constructor.timelineId() or @episode.timelineId()

  @finished: -> false # Override to set goal state conditions.
  finished: -> @constructor.finished()

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
      
  active: ->
    # Chapter starts being active when the previous chapter gets finished. It stays active forever to preserve 
    # inventory and other permanent changes, as well as access to unfinished sections. First chapter is special and
    # gets activated when episode's starting section gets completed.
    if @previousChapter then @previousChapter.finished() else @episode.startSection.finished()

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
    # Create new chapter title.
    chapterTitle = new LOI.Components.ChapterTitle _.extend {}, options,
      chapter: @

    LOI.adventure.showActivatableModalDialog
      dialog: chapterTitle

    # Wait till chapter title gets activated.
    @autorun (computation) =>
      return unless chapterTitle.activatable.activated()
      computation.stop()

      options.onActivated?()
