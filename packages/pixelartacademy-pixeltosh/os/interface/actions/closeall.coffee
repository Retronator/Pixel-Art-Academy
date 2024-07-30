AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.OS.Interface.Actions.CloseAll extends PAA.Pixeltosh.OS.Interface.Actions.Action
  @id: -> 'PixelArtAcademy.Pixeltosh.OS.Interface.Actions.CloseAll'
  @displayName: -> "Close All"

  @initialize()
  
  enabled: ->
    # We can perform a close all action when we have any folder windows open.
    @interface.allChildComponentsOfType(PAA.Pixeltosh.Programs.Finder.Folder).length
  
  execute: ->
    windows = @interface.currentLayoutData().get 'windows'
    
    for windowId of windows
      window = @interface.getWindow windowId
      @os.removeWindow windowId if window.allChildComponentsOfType(PAA.Pixeltosh.Programs.Finder.Folder).length
