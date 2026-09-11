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
      if projectId = PAA.Pico8.Cartridges.Invasion.Project.state 'activeProjectId'
        if LM.Design.Fundamentals.Goals.Invasion.Start.completed()
          if @_invasion?.projectId isnt projectId
            @_invasion?.destroy()
            @_invasion = Tracker.nonreactive => new PAA.Pico8.Cartridges.Invasion.Project projectId
    
          things.push @_invasion

    things
