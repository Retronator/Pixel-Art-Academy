LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Workbench extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Workbench'

  @location: -> PAA.Practice.Project.Workbench

  @initialize()

  destroy: ->
    super arguments...

    @_snake?.destroy()

  things: ->
    return unless LM.Intro.Tutorial.Goals.Snake.active()
    
    things = []

    if projectId = PAA.Pico8.Cartridges.Snake.Project.state 'activeProjectId'
      @_snake?.destroy()
      @_snake = new PAA.Pico8.Cartridges.Snake.Project projectId

      things.push @_snake

    things
