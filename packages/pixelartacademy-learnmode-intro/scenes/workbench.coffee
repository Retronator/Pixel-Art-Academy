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

    if LM.Intro.Tutorial.Goals.Snake.addedAndAvailable()
      if PAA.Pico8.Cartridges.Snake.Project.visible()
        @_snake ?= Tracker.nonreactive => new PAA.Pico8.Cartridges.Snake.Project
        things.push @_snake

    things
