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
    things = []

    if LM.Intro.Tutorial.Goals.Snake.available()
      if projectId = PAA.Pico8.Cartridges.Snake.Project.state 'activeProjectId'
        if @_snake?.projecId isnt projectId
          @_snake?.destroy()
          @_snake = Tracker.nonreactive => new PAA.Pico8.Cartridges.Snake.Project projectId
  
        things.push @_snake

    things
