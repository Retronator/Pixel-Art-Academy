AE = Artificial.Everywhere
AB = Artificial.Base
PAA = PixelArtAcademy

class PAA.Pico8.Cartridges.Invasion.Project extends PAA.Practice.Project.Thing
  # Project document fields
  # design: the design options
  #   theme: a theme ID used to provide references
  #   [entities]: an array of entity IDs added to the game
  #   defender:
  #     movement: whether the defender moves horizontally, vertically, or in all 4 directions
  #     startingAlignment: where does the defender appear
  #       horizontal, vertical
  # designDocument: data related to the display of the design document
  #   [writtenUnits]: an array of unit IDs that have already been written
  @id: -> 'PixelArtAcademy.Pico8.Cartridges.Invasion.Project'
  
  @fullName: -> "Invasion game"

  @assetsProviderClass: -> @AssetsProvider

  @visible: -> LM.Design.Fundamentals.Goals.Invasion.Start.completed()

  @editable: -> LM.Design.Fundamentals.Goals.Invasion.completed()

  @initialize()

  constructor: ->
    super arguments...
    
    @pico8Cartridge = new PAA.Pico8.Cartridges.Invasion

  destroy: ->
    super arguments...
    
    @pico8Cartridge.destroy()

  content: ->
    return unless chapter = LOI.adventure.getCurrentChapter LM.Design.Fundamentals
    chapter.getContent LM.Design.Fundamentals.Content.Projects.Invasion
