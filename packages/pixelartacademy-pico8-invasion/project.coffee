AE = Artificial.Everywhere
AB = Artificial.Base
PAA = PixelArtAcademy

class PAA.Pico8.Cartridges.Invasion.Project extends PAA.Practice.Project.Thing
  # activeProjectId: ID of the project that is currently active
  
  # Project document fields
  # design: the design options
  #   subtitle: a string displayed on the splash screen
  @id: -> 'PixelArtAcademy.Pico8.Cartridges.Invasion.Project'
  
  @fullName: -> "Invasion game"

  @initialize()

  constructor: ->
    super arguments...

    @assets = new AE.LiveComputedField =>
      [
        new PAA.Pico8.Cartridges.Invasion.Defender @
      ]
    
    @pico8Cartridge = new PAA.Pico8.Cartridges.Invasion

  destroy: ->
    @assets.stop()
    @pico8Cartridge.destroy()
    
  content: ->
    return unless chapter = LOI.adventure.getCurrentChapter LM.Design.Fundamentals
    chapter.getContent LM.Design.Fundamentals.Content.Projects.Invasion
