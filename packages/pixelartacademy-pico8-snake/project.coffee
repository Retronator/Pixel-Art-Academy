AB = Artificial.Base
PAA = PixelArtAcademy

class PAA.Pico8.Cartridges.Snake.Project extends PAA.Practice.Project.Thing
  # activeProjectId: ID of the project that is currently active
  @id: -> 'PixelArtAcademy.Pico8.Cartridges.Snake.Project'
  
  @fullName: -> "Snake game"

  @initialize()

  constructor: ->
    super arguments...

    @_assets = Tracker.nonreactive => [
      new PAA.Pico8.Cartridges.Snake.Food @
      new PAA.Pico8.Cartridges.Snake.Body @
    ]
    
    @pico8Cartridge = new PAA.Pico8.Cartridges.Snake

  destroy: ->
    asset.destroy() for asset in @_assets
    @pico8Cartridge.destroy()

  assets: -> @_assets
    
  content: ->
    return unless chapter = LOI.adventure.getCurrentChapter PAA.LearnMode.Intro.Tutorial
    chapter.getContent PAA.LearnMode.Intro.Tutorial.Content.Projects.Snake
