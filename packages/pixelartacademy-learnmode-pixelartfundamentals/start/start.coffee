LOI = LandsOfIllusions
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Start extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Start'

  @scenes: -> []

  @initialize()

  @started: -> true

  @finished: ->
    return unless LOI.adventureInitialized()
    
    # Allow cheating.
    return true if LM.PixelArtFundamentals.state 'unlocked'
    
    # Pixel art fundamentals start after the intro is finished.
    return false unless tutorial = Tracker.nonreactive => LOI.adventure.getCurrentChapter LM.Intro.Tutorial
    
    tutorial.finished()
