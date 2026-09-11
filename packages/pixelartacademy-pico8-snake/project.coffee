AB = Artificial.Base
PAA = PixelArtAcademy

class PAA.Pico8.Cartridges.Snake.Project extends PAA.Practice.Project.Thing
  @id: -> 'PixelArtAcademy.Pico8.Cartridges.Snake.Project'
  
  @fullName: -> "Snake game"

  @assetsProviderClass: -> @AssetsProvider
  
  @visible: -> LM.Intro.Tutorial.Goals.Snake.Play.completed()
  
  @editable: -> LM.Intro.Tutorial.Goals.Snake.completed()
  
  @initialize()

  constructor: ->
    super arguments...

    @pico8Cartridge = new PAA.Pico8.Cartridges.Snake

  destroy: ->
    @pico8Cartridge.destroy()
    
  content: ->
    return unless chapter = LOI.adventure.getCurrentChapter PAA.LearnMode.Intro.Tutorial
    chapter.getContent PAA.LearnMode.Intro.Tutorial.Content.Projects.Snake
