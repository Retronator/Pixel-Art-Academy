AB = Artificial.Base
AC = Artificial.Control
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelPad extends PAA.PixelPad
  backButtonVisible: -> @os.currentAppUrl()
  
  backButtonCallback: ->
    =>
      # If we have focused artworks, we need to close them.
      if LOI.adventure.interface.focusedArtworks()
        LOI.adventure.interface.unfocusArtworks()
      
      else if @backButtonVisible()
        @os.backButtonCallback()
        
      else
        # When the back button is not visible, we should open the menu (if it's not open already).
        LOI.adventure.menu.showMenu() unless LOI.adventure.menu.visible()
  
      # Instruct the back button to cancel closing (so it doesn't disappear).
      cancel: true
