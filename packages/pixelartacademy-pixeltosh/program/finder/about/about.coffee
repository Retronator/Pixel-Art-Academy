AM = Artificial.Mirage
AEc = Artificial.Echo
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.Programs.Finder.About extends FM.Dialog
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Finder.About'
  @register @id()
  
  @createInterfaceData: ->
    contentComponentId: @id()
    left: 60
    top: 74
    width: 200
    
  onRendered: ->
    # Listen to click events on the parent dialog area.
    @$('.pixelartacademy-pixeltosh-programs-finder-about').closest('.dialog-area').on 'click', => @closeDialog()
