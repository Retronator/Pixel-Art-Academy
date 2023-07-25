AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Menu.Progress.Content.DefaultContent extends LM.Menu.Progress.Content.Component
  @id: -> 'PixelArtAcademy.LearnMode.Menu.Progress.Content.DefaultContent'
  @register @id()
  
  showUnlockInstructions: ->
    # Only show when in game.
    return unless @progress.inGame()
    
    # Show when locked.
    content = @data()
    not content.unlocked()
