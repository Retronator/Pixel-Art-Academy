AB = Artificial.Base
PAA = PixelArtAcademy

class PAA.Pico8.Cartridges.Snake.Project extends PAA.Practice.Project.Thing
  # activeProjectId: ID of the project that is currently active
  @id: -> 'PixelArtAcademy.Pico8.Cartridges.Snake'
  
  @fullName: -> "Snake game"

  @initialize()

  constructor: ->
    super arguments...

    @assets = new ComputedField =>
      [
        new PAA.Pico8.Cartridges.Snake.Body @
        new PAA.Pico8.Cartridges.Snake.Food @
      ]
    ,
      true
    
    @pico8Cartridge = new PAA.Pico8.Cartridges.Snake

  destroy: ->
    @assets.stop()
    @pico8Cartridge.destroy()