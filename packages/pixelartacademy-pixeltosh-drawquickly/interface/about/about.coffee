AM = Artificial.Mirage
AEc = Artificial.Echo
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

class DrawQuickly.Interface.About extends FM.Dialog
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.DrawQuickly.Interface.About'
  @register @id()
  
  @createInterfaceData: ->
    contentComponentId: @id()
    left: 60
    top: 74
    width: 200
    
  onRendered: ->
    # Listen to click events on the parent dialog area.
    @$('.pixelartacademy-pixeltosh-programs-drawquickly-interface-about').closest('.dialog-area').on 'click', => @closeDialog()
