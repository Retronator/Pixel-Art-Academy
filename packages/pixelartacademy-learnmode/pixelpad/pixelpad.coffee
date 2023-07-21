AB = Artificial.Base
AC = Artificial.Control
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelPad extends PAA.PixelPad
  backButtonVisible: -> @os.currentAppUrl()
  
  backButtonCallback: ->
    =>
      if @backButtonVisible()
        @os.backButtonCallback()
        
      else
        # When the back button is not visible, we should open the menu (if it's not open already).
        LOI.adventure.menu.showMenu() unless LOI.adventure.menu.menuVisible()
  
      # Instruct the back button to cancel closing (so it doesn't disappear).
      cancel: true
