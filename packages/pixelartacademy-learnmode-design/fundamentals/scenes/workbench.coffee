LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Design.Fundamentals.Workbench extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Workbench'

  @location: -> PAA.Practice.Project.Workbench

  @initialize()

  destroy: ->
    super arguments...

    @_invasion?.destroy()

  things: ->
    things = []

    if LM.Design.Fundamentals.Goals.Invasion.addedAndAvailable()
      if PAA.Pico8.Cartridges.Invasion.Project.visible()
        @_invasion ?= Tracker.nonreactive => new PAA.Pico8.Cartridges.Invasion.Project
        things.push @_invasion

    things
