LOI = LandsOfIllusions
LM = PixelArtAcademy.LearnMode

class LM.Design.Start extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.LearnMode.Design.Start'

  @scenes: -> []

  @initialize()

  @started: -> true

  @finished: ->
    return unless LOI.adventureInitialized()
    
    # Allow cheating.
    return true if LM.Design.state 'unlocked'
    
    # Design starts after the element of art shape lesson is completed.
    PAA.Tutorials.Drawing.ElementsOfArt.Shape.completed()
