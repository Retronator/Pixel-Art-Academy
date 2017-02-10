LOI = LandsOfIllusions

class LOI.Adventure.Chapter
  @sections: -> throw new AE.NotImplementedException

  constructor: ->
    @sections = for sectionClass in @constructor.sections()
      new sectionClass

  currentSections: ->
    section for section in @sections when section.active()
