AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.Programs.Finder.Actions.Close extends PAA.Pixeltosh.OS.Interface.Actions.Action
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Finder.Actions.Close'
  @displayName: -> "Close"

  @initialize()
  
  enabled: ->
    # We can perform a close action when a folder is the active window.
    return unless activeWindow = @interface.getWindow @os.activeWindowId()
    
    activeWindow.allChildComponentsOfType(PAA.Pixeltosh.Programs.Finder.Folder).length
  
  execute: ->
    @os.removeWindow @os.activeWindowId()
