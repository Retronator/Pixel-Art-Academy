LOI = LandsOfIllusions

class LOI.Adventure.Chapter extends LOI.Adventure.Thing
  @sections: -> throw new AE.NotImplementedException

  constructor: (@options) ->
    super

    @episode = @options.episode

    @sections = for sectionClass in @constructor.sections()
      new sectionClass chapter: @
      
  destroy: ->
    super

    section.destroy() for section in @sections
    @sections = []

  currentSections: ->
    section for section in @sections when section.active()

  ready: ->
    # Chapter is ready when all its sections are ready.
    conditions = _.flattenDeep [
      super
      (section.ready() for section in @sections)
    ]

    _.every conditions
