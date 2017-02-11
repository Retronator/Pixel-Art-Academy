LOI = LandsOfIllusions

class LOI.Adventure.Chapter extends LOI.Adventure.Thing
  @sections: -> throw new AE.NotImplementedException

  constructor: ->
    super
    
    @sections = for sectionClass in @constructor.sections()
      new sectionClass

  currentSections: ->
    section for section in @sections when section.active()
