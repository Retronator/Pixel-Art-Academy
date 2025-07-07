AB = Artificial.Base
PAA = PixelArtAcademy

class PAA.Pico8.Cartridges.Invasion.Project extends PAA.Practice.Project.Thing
  # activeProjectId: ID of the project that is currently active
  @id: -> 'PixelArtAcademy.Pico8.Cartridges.Invasion'
  
  @fullName: -> "Invasion game"

  @initialize()

  constructor: ->
    super arguments...

    @assets = new ComputedField =>
      [
        new PAA.Pico8.Cartridges.Invasion.Body @
        new PAA.Pico8.Cartridges.Invasion.Food @
      ]
    ,
      true
    
    @pico8Cartridge = new PAA.Pico8.Cartridges.Invasion

  destroy: ->
    @assets.stop()
    @pico8Cartridge.destroy()
    
  content: ->
    return unless chapter = LOI.adventure.getCurrentChapter PAA.LearnMode.Intro.Tutorial
    chapter.getContent PAA.LearnMode.Intro.Tutorial.Content.Projects.Invasion
