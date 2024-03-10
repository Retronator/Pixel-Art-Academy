FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.OS.Interface.TitleBar extends FM.View
  # caption: string to display in the title bar
  @id: -> 'PixelArtAcademy.Pixeltosh.OS.Interface.TitleBar'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @os = @interface.parent
  
  activeClass: ->
    view = @ancestorComponentOfType PAA.Pixeltosh.Program.View
    'active' if view.active()
