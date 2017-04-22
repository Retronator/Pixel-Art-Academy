LOI = LandsOfIllusions

class LOI.Adventure.Chapter extends LOI.Adventure.Thing
  @register 'LandsOfIllusions.Adventure.Chapter'
  template: -> 'LandsOfIllusions.Adventure.Chapter'

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
    super

    @episode = @options.episode

    @sections = for sectionClass in @constructor.sections()
      new sectionClass parent: @
      
    @chapterTitle = new ReactiveField null

  destroy: ->
    super

    section.destroy() for section in @sections
    @sections = []

  getSection: (sectionClassOrId) ->
    sectionId = _.thingId sectionClassOrId

    _.find @sections, (section) => section.id() is sectionId
      
  scenes: -> # Override to provide any scenes for the whole chapter.

  active: ->
    @_activeUntilFinished()

  _activeUntilFinished: ->
    # Override and add additional logic to create prerequisites for the section being started.
    finished = @finished()

    # Finished can return undefined, which means it is not ready to determine its state.
    return unless finished?

    # By default the section is active until it is finished.
    not finished

  requireFinishedSections: (sections) ->
    # Allow for passing of a single section.
    sections = [sections] unless _.isArray sections

    # See if sections are finished.
    return unless section.finished() for section in sections

    true
    
  currentSections: ->
    section for section in @sections when section.active()

  ready: ->
    # Chapter is ready when all its sections are ready.
    conditions = _.flattenDeep [
      super
      (section.ready() for section in @sections)
    ]

    _.every conditions

  showChapterTitle: (options = {}) ->
    # Create new chapter title.
    chapterTitle = new LOI.Components.ChapterTitle _.extend {}, options,
      chapter: @

    @chapterTitle chapterTitle

    # Wait till chapter title gets rendered.
    @autorun (computation) =>
      return unless chapterTitle.isRendered()
      computation.stop()

      chapterTitle.activatable.activate()

    # Wait till chapter title gets activated.
    @autorun (computation) =>
      return unless chapterTitle.activatable.activated()
      computation.stop()

      options.onActivated?()
