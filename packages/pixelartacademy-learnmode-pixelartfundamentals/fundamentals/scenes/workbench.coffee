LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

Pinball = PAA.Pixeltosh.Programs.Pinball
Chess = PAA.Pixeltosh.Programs.Chess

class LM.PixelArtFundamentals.Fundamentals.Workbench extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Workbench'

  @location: -> PAA.Practice.Project.Workbench

  @initialize()

  destroy: ->
    super arguments...

    @_pinball?.destroy()
    @_chess2D?.destroy()

  things: ->
    things = []
    
    if LM.PixelArtFundamentals.Fundamentals.Goals.Pinball.addedAndAvailable()
      if Pinball.Project.visible()
        @_pinball ?= Tracker.nonreactive => new Pinball.Project
        things.push @_pinball
        
    if LM.PixelArtFundamentals.Fundamentals.Goals.Chess.addedAndAvailable()
      if Chess.Project.TwoDimensional.visible()
        @_chess2D ?= Tracker.nonreactive => new Chess.Project.TwoDimensional
        things.push @_chess2D

    things
